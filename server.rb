require 'rubygems'
require 'bundler'
Bundler.require

MAX_REDIRECTS = ENV.fetch('MAX_REDIRECTS', 10).to_i
WAIT_TIMEOUT = ENV.fetch('WAIT_TIMEOUT', 30).to_i # seconds
PATH_PATTERN = Regexp.new(ENV.fetch('PATH_PATTERN', '.*'))

S3_CLIENT = Aws::S3::Client.new(credentials: Aws::SharedCredentials.new)
S3_BUCKET = ENV.fetch('AWS_S3_BUCKET')
PRESIGNER = Aws::S3::Presigner.new(client: S3_CLIENT)

get '/healthcheck' do
  'ok'
end

get '/*path' do
  halt 404, 'Not Found' unless params[:path] =~ PATH_PATTERN
  presigned_url = future(:wait_for_presigned_url, params[:path]).value
  if presigned_url.nil?
    halt 504, 'Gateway Timeout' if params[:redirect].to_i >= (MAX_REDIRECTS - 1)
    redirect "/#{params[:path]}?redirect=#{params[:redirect].to_i + 1}"
  else
    redirect presigned_url
  end
end

task :wait_for_presigned_url do |key|
  started_at = Time.now
  object = Aws::S3::Object.new(S3_BUCKET, key, client: S3_CLIENT)
  found = nil
  loop do
    break if found = object.exists?
    break if (Time.now - started_at).to_i >= WAIT_TIMEOUT
    sleep 1
  end
  found ?
    PRESIGNER.presigned_url(:get_object, bucket: 'viaeurope-staging', key: key) :
    nil
end

