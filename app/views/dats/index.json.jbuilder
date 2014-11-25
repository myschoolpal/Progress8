json.array!(@dats) do |dat|
  json.extract! dat, :id
  json.url dat_url(dat, format: :json)
end
