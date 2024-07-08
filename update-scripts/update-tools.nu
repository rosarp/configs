#!/usr/bin/env nu

rustup update
rustup component add rust-analyzer
cargo install-update -a

# expect /home/$user/bin present
http get https://ziglang.org/download/index.json | get master.version | wget -O ~/bin/zig-linux-x86_64.tar.xz https://ziglang.org/builds/zig-linux-x86_64-$'($in)'.tar.xz
if ('~/bin/zig' | path exists) {
  rm ~/bin/zig
}
if ('~/bin/zig-linux-x86_64' | path exists) {
  rm -r ~/bin/zig-linux-x86_64
}
mkdir ~/bin/zig-linux-x86_64 | tar xf ~/bin/zig-linux-x86_64.tar.xz -C ~/bin/zig-linux-x86_64 --strip-components 1
if ('~/bin/zig-linux-x86_64.tar.xz' | path exists) {
  rm ~/bin/zig-linux-x86_64.tar.xz
}
ln -s ~/bin/zig-linux-x86_64/zig ~/bin/zig

# expect /home/$user/bin present
# expect zls src at ~/workspace/repository/zls/
if ('~/workspace/repository/zls/' | path exists) {
  cd ~/workspace/repository/zls/
  git pull origin master
  zig build -Doptimize=ReleaseSafe
  rm ~/bin/zls
  cp ./zig-out/bin/zls ~/bin/zls
  cd ~/
} else {
  echo "To install zls, download repo and update above path"
}
