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
    let zig_pre_version = (cat ~/bin/zig.version)
    let zig_new_version = (http get https://ziglang.org/download/index.json | get master.version)
    if $zig_pre_version != $zig_new_version {
      print $"New 'zig' version available: ($zig_pre_version) < ($zig_new_version)"
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
      print $"No new 'zig' version available: ($zig_new_version)"
    }
  } else {
    print "To install zig, create bin folder under home directory."
  }
}

def "main update_zls" [] {
  # expect zls src at ~/workspace/zig-workspace/repository/zls/
  if ('~/workspace/zig-workspace/repository/zls/' | path exists) {
    cd ~/workspace/zig-workspace/repository/zls/
    let git_out = (git pull origin master --depth=1)
    print $git_out
    cp ./zig-out/bin/zls ./zls-bak
    if "Already up to date." != $git_out {
      zig build -Doptimize=ReleaseSafe
      if ($env.LAST_EXIT_CODE == 1) {
        mkdir -v ./zig-out/bin
        mv ./zls-bak ./zig-out/bin/zls
      } else {
        rm ./zls-bak
      }
    }
    if ('~/bin/zig-linux-x86_64/zls' | path exists) {
      rm ~/bin/zig-linux-x86_64/zls
    }
    if ('~/bin/zls' | path exists) {
      rm ~/bin/zls
    }
    if ('./zig-out/bin/zls' | path exists) {
      cp ./zig-out/bin/zls ~/bin/zig-linux-x86_64/zls
      ln -fs ~/bin/zig-linux-x86_64/zls ~/bin/zls
    }
  } else {
    print "To install zls, download repo and update above path"
  }
}

def "main switch_zig" [zig_version?: string] {
  if ('~/bin/zig' | path exists) {
    rm ~/bin/zig
  }
  if ('~/bin/zls' | path exists) {
    rm ~/bin/zls
  }
  match $zig_version {
    null => {
      ln -s ~/bin/zig-linux-x86_64/zig ~/bin/zig
      ln -s ~/bin/zig-linux-x86_64/zls ~/bin/zls
    }
    _ => {
      if not ($'~/bin/zig-linux-x86_64-($zig_version)/zig' | path exists) {
        return "BAD VERSION"
      }
      ln -s ~/bin/zig-linux-x86_64-($zig_version)/zig ~/bin/zig
      ln -s ~/bin/zig-linux-x86_64-($zig_version)/zls ~/bin/zls
    }
  }
}
