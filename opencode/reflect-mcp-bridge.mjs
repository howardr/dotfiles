#!/usr/bin/env node

/**
 * Reflect Desktop MCP Bridge
 * 
 * Proxies stdio MCP communication from OpenCode to Reflect Desktop's
 * local HTTP endpoint (http://127.0.0.1:7676/mcp).
 * 
 * Fixes:
 * 1. Strictly formats HTTP Accept headers required by Reflect.
 * 2. Sanitizes tool schemas (e.g., converts numeric const/enums like `level` 1..6 
 *    in `update_block_attributes` into integer ranges) to prevent Google Gemini 
 *    and other strict OpenAPI LLMs from throwing TYPE_STRING schema validation errors.
 * 3. Gracefully handles Reflect.app being closed without crashing OpenCode.
 */

import readline from "node:readline";

const REFLECT_URL = process.env.REFLECT_MCP_URL || "http://127.0.0.1:7676/mcp";

function log(...args) {
  process.stderr.write(`[reflect-bridge] ${args.join(" ")}\n`);
}

function sanitizeSchema(schema) {
  if (!schema || typeof schema !== "object") return schema;
  if (Array.isArray(schema)) return schema.map(sanitizeSchema);

  const copy = { ...schema };

  // Convert anyOf of numeric consts (like ProseMirror level 1..6) to integer range
  if (
    Array.isArray(copy.anyOf) &&
    copy.anyOf.length > 0 &&
    copy.anyOf.every((item) => typeof item?.const === "number")
  ) {
    const nums = copy.anyOf.map((item) => item.const).sort((a, b) => a - b);
    return {
      type: "integer",
      minimum: nums[0],
      maximum: nums[nums.length - 1],
      description: copy.description || `Integer between ${nums[0]} and ${nums[nums.length - 1]}`
    };
  }

  // Convert numeric enum to integer min/max range
  if (Array.isArray(copy.enum) && copy.enum.some((v) => typeof v === "number")) {
    const nums = copy.enum.filter((v) => typeof v === "number").sort((a, b) => a - b);
    delete copy.enum;
    copy.type = "integer";
    copy.minimum = nums[0];
    copy.maximum = nums[nums.length - 1];
  }

  for (const [key, val] of Object.entries(copy)) {
    copy[key] = sanitizeSchema(val);
  }
  return copy;
}

function sanitizeTool(tool) {
  if (!tool || typeof tool !== "object") return tool;
  const sanitized = { ...tool };
  if (sanitized.inputSchema) {
    sanitized.inputSchema = sanitizeSchema(sanitized.inputSchema);
  }
  return sanitized;
}

async function forwardToReflect(request) {
  try {
    const response = await fetch(REFLECT_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream"
      },
      body: JSON.stringify(request)
    });

    if (!response.ok) {
      const errText = await response.text();
      return {
        jsonrpc: "2.0",
        id: request.id ?? null,
        error: {
          code: -32603,
          message: `Reflect HTTP error ${response.status}: ${errText}`
        }
      };
    }

    const text = await response.text();
    // Parse SSE format: extract data line
    const dataLine = text.split("\n").find((l) => l.startsWith("data: "));
    if (dataLine) {
      const parsed = JSON.parse(dataLine.slice(6));
      return parsed;
    }

    // Fallback: try parsing whole body as JSON
    return JSON.parse(text);
  } catch (err) {
    log(`Reflect connection error: ${err.message}`);
    return null;
  }
}

async function handleMessage(msg) {
  // Handle empty or invalid
  if (!msg || typeof msg !== "object") return;

  // Notifications (no id)
  if (msg.id === undefined || msg.id === null) {
    if (msg.method === "notifications/initialized") {
      // Reflect doesn't strictly need this, but we can attempt forwarding
      await forwardToReflect(msg);
    }
    return;
  }

  const { id, method } = msg;

  // 1. Initialize
  if (method === "initialize") {
    const reflectRes = await forwardToReflect(msg);
    if (reflectRes && reflectRes.result) {
      respond(reflectRes);
    } else {
      // Fallback if Reflect is down
      respond({
        jsonrpc: "2.0",
        id,
        result: {
          protocolVersion: "2024-11-05",
          capabilities: { tools: { listChanged: true } },
          serverInfo: { name: "reflect-desktop-bridge", version: "1.0.0" }
        }
      });
    }
    return;
  }

  // 2. Tools list
  if (method === "tools/list") {
    const reflectRes = await forwardToReflect(msg);
    if (reflectRes && reflectRes.result && Array.isArray(reflectRes.result.tools)) {
      const sanitizedTools = reflectRes.result.tools.map(sanitizeTool);
      respond({
        jsonrpc: "2.0",
        id,
        result: {
          ...reflectRes.result,
          tools: sanitizedTools
        }
      });
    } else {
      // Reflect not reachable
      respond({
        jsonrpc: "2.0",
        id,
        result: { tools: [] }
      });
    }
    return;
  }

  // 3. All other methods (tools/call, ping, etc.)
  const reflectRes = await forwardToReflect(msg);
  if (reflectRes) {
    respond(reflectRes);
  } else {
    respond({
      jsonrpc: "2.0",
      id,
      error: {
        code: -32000,
        message: "Reflect Desktop is currently offline or unreachable at " + REFLECT_URL
      }
    });
  }
}

function respond(obj) {
  process.stdout.write(JSON.stringify(obj) + "\n");
}

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on("line", (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  try {
    const msg = JSON.parse(trimmed);
    handleMessage(msg);
  } catch (err) {
    log(`JSON parse error: ${err.message}`);
  }
});
