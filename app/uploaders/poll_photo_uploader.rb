# encoding: utf-8

class PollPhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include ::CarrierWave::Backgrounder::Delay

  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  process resize_to_limit: [400, 400]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
