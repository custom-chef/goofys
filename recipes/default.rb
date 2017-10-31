#
# Cookbook:: goofys
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

["golang", "fuse"].each do |package|
  package "#{package}"
end

directory "/var/s3" do
    owner "deploy"
    group "deploy"
    recursive true
    mode 0775
    action :create
end

bash "install goofys" do
    user "root"
    environment "GOPATH" => "/root/go"
    code <<-EOS
        go get github.com/kahing/goofys
        go install github.com/kahing/goofys
    EOS
    not_if { File.exists?('/root/go/bin/goofys') }
end

execute "write fstab" do
    user "root"
    command "echo '/root/go/bin/goofys#affi-test-s3 /var/s3/ fuse _netdev,allow_other,--file-mode=0664,--dir-mode=0775,--uid=1000,--gid=1000 0 0' >> /etc/fstab"
    not_if "cat /etc/fstab | awk '{print $2}' |grep '/var/s3/'"
end

execute "mount s3" do
    user "root"
    command 'mount -a'
    not_if { Dir.exists?('/var/s3/file') }
end

directory "/var/s3/file" do
    owner "deploy"
    group "deploy"
    recursive true
    mode 0775
    action :create
end
