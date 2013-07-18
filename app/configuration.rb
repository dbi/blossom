self.omx_symbols = {
  "indu-c" => "SSE3966",
  "kinnevik-b" => "SSE999",
  "ratos-b" => "SSE1045",
  "duni" => "SSE49775",
  "hm-b" => "SSE992"
}

if defined? Rspec
  # settings only for test environment
else
  # production persistance etc.
end
