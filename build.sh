set -x

rm -rf tmp
mkdir tmp

local_pwd=`pwd`

touch "$local_pwd"/tmp/Session.modulevalidation

echo "========= build c.pch ========="
clang -x objective-c-header -F "$local_pwd" -fmodules -fbuild-session-file\="$local_pwd"/tmp/Session.modulevalidation -fmodules-validate-once-per-build-session -fmodules-cache-path="$local_pwd"/tmp \
 -c "$local_pwd"/c.pch -o "$local_pwd"/tmp/c.pch.gch

find . -name "A-*.pcm" | xargs llvm-bcanalyzer   --dump > tmp/1.log
find . -name "*.pcm" | xargs md5
find . -name "*.pcm" | xargs ls -l

echo "========= delete A-xxx.pcm & build d.pch ========="
find . -name "A-*.pcm" | xargs rm

cd libD

clang -x objective-c-header -F "$local_pwd"/ -fmodules -fbuild-session-file\="$local_pwd"/tmp/Session.modulevalidation -fmodules-validate-once-per-build-session -fmodules-cache-path="$local_pwd"/tmp \
 -c "$local_pwd"/libD/d.pch -o "$local_pwd"/tmp/d.pch.gch

find . -name "*.pcm" | xargs md5

echo "========= build d.m ========="

clang -fmodules -fbuild-session-file\="$local_pwd"/tmp/Session.modulevalidation -fmodules-validate-once-per-build-session -fmodules-cache-path="$local_pwd"/tmp \
 -c "$local_pwd"/libD/d.m -o "$local_pwd"/tmp/d.o -include "$local_pwd"/tmp/d.pch -F "$local_pwd"/

cd ..

find . -name "A-*.pcm" | xargs llvm-bcanalyzer   --dump > tmp/2.log

find . -name "*.pcm" | xargs md5

echo "========= build c.m ========="
clang -fmodules -fbuild-session-file\="$local_pwd"/tmp/Session.modulevalidation -fmodules-validate-once-per-build-session -fmodules-cache-path="$local_pwd"/tmp \
 -c "$local_pwd"/c.m -o "$local_pwd"/tmp/c.o -include "$local_pwd"/tmp/c.pch -F "$local_pwd"

find . -name "*.pcm" | xargs md5

rg SOURCE_MANAGER_LINE_TABLE tmp
