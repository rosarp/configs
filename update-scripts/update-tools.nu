#!/usr/bin/env nu

def main [] {
  if (true) {
    main update_rust
  }

  if (false) {
    main update_zig
  }

  if (false) {
    # IC toolchain update
    dfxvm update
  }

  if (true) {
    bun upgrade --stable
  }
}

# rust toolchain update
def "main update_rust" [] {
  rustup update
  rustup component add rust-analyzer
  cargo install-update -a
}

# zig toolchain update
def "main update_zig" [] {
  # expect ~/bin folder already present
  if ('~/bin/' | path exists) {
    let zig_pre_version = ^'cat' ~/bin/zig.version
    let zig_new_version = (http get https://ziglang.org/download/index.json | get master.version)
    if $zig_pre_version != $zig_new_version {
      "New 'zig' version available:" | append $zig_pre_version | append "<" | append $zig_new_version | str join " " | print $in
      $zig_new_version | wget -O ~/bin/zig-linux-x86_64.tar.xz https://ziglang.org/builds/zig-linux-x86_64-$'($in)'.tar.xz
      if ('~/bin/zig' | path exists) {
        rm ~/bin/zig
      }
      if ('~/bin/zig-linux-x86_64' | path exists) {
        rm -r ~/bin/zig-linux-x86_64/*
      } else {
        mkdir ~/bin/zig-linux-x86_64 
      }
      tar xf ~/bin/zig-linux-x86_64.tar.xz -C ~/bin/zig-linux-x86_64 --strip-components 1
      if ('~/bin/zig-linux-x86_64.tar.xz' | path exists) {
        rm ~/bin/zig-linux-x86_64.tar.xz
      }
      ln -s ~/bin/zig-linux-x86_64/zig ~/bin/zig
      $zig_new_version | save -f ~/bin/zig.version

      # update zls if zig is updated
      main update_zls
    } else {
      "No new 'zig' version available:" | append $zig_new_version | str join " " | print $in
    }
  } else {
    print "To install zig, create bin folder under home directory."
  }
}

def "main update_zls" [] {
  # expect zls src at ~/workspace/repository/zls/
  if ('~/workspace/repository/zls/' | path exists) {
    cd ~/workspace/repository/zls/
    let git_out = (git pull origin master)
    print $git_out
    if "Already up to date." != $git_out {
      zig build -Doptimize=ReleaseSafe
    }
    if ('~/bin/zig-linux-x86_64/zls' | path exists) {
      rm ~/bin/zig-linux-x86_64/zls
    }
    cp ./zig-out/bin/zls ~/bin/zig-linux-x86_64/zls
    if ('~/bin/zls' | path exists) {
      rm ~/bin/zls
    }
    ln -s ~/bin/zig-linux-x86_64/zls ~/bin/zls
  } else {
    print "To install zls, download repo and update above path"
  }
}
