local config = {
  c = {
    { {'gcc', '$fileName.c', '-o', '$fileName'}, exceptCode = 0 },
    { {'./$fileName'} },
    { {'rm', '$fileName', '-rf'} }
  },
}
return config
