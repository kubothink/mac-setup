# dotfilesディレクトリを作成
mkdir -p files/dotfiles

# 存在するdotfilesをコピー
for file in .gitconfig .zshrc .vimrc .bash_profile .bashrc .profile .zprofile .zshenv .p10k.zsh .tmux.conf .ideavimrc .gemrc .npmrc .tool-versions; do
  if [ -f ~/$file ]; then
    cp ~/$file files/dotfiles/${file#.}
    echo "Copied $file"
  fi
done