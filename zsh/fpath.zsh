# add each topic folder to fpath so that they can add functions and completion
# scripts. Sourced explicitly by zshrc before compinit runs.
for topic_folder ($DOTFILES/*(/)) fpath=($topic_folder $fpath)
unset topic_folder
