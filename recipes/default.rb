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
    mode 0755
    action :create
end

execute "install goofys" do
    user "root"
    command <<-EOC
        export GOPATH=$HOME/go
        go get github.com/kahing/goofys
        go install github.com/kahing/goofys
        S3_MOUNT_DIR=/var/s3
        S3_BUCKET_NAME=affi-test-s3
        $HOME/go/bin/goofys --uid=1000 --gid=1000 ${S3_BUCKET_NAME} ${S3_MOUNT_DIR}
    EOC
end

directory "/var/s3/file" do
    owner "deploy"
    group "deploy"
    recursive true
    mode 0755
    action :create
end
