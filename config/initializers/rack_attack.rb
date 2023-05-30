class Rack::Attack
  throttle('requests per minute per ip', limit: 100, period: 1.minute) do |req|
    req.ip
  end
end
