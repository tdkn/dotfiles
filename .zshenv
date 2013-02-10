# Android SDK
if [ -d /opt/android ]; then
  export PATH="/opt/android/android-sdk-linux/tools:$PATH"
fi

ANDROID_SDK="$HOME/Development/adt-bundle-linux-x86/sdk"
if [ -d ${ANDROID_SDK} ]; then
  export PATH="$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools:$PATH"
fi

# rbenv
if [ -d ${HOME}/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  source $HOME/.rbenv/completions/rbenv.zsh
fi
