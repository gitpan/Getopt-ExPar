#!/bin/csh -f

setenv D_int43 123
setenv D_int44 123
setenv D_int45 23
setenv D_int46 123
setenv D_int67 123
setenv D_int68 123
setenv D_int69 '(123, 456)'
setenv D_int70 '(123, 456)'

setenv D_real43 123.0
setenv D_real44 123.0
setenv D_real45 23.0
setenv D_real46 123.0
setenv D_real67 123.0
setenv D_real68 123.0
setenv D_real69 '(123.0, 456.0)'
setenv D_real70 '(123.0, 456.0)'

setenv D_string17 '("s17")'
setenv D_string18 '("s18a")'
setenv D_string19 '("s19a")'
setenv D_string20a '("s20a")'

setenv D_name17 '("n17")'
setenv D_name18 '("n18a")'
setenv D_name19 '("n19a")'
setenv D_name20a '("n20a")'

setenv D_file17 '("f17")'
setenv D_file18 '("f18a")'
setenv D_file19 '("f19a")'
setenv D_file20a '("f20a")'

setenv D_application17 '("`date`")'
setenv D_application18 '("`time ls`")'
setenv D_application19 '("`cal`")'
setenv D_application20a '("`date`")'

setenv D_key11 '("text")'
setenv D_keys13 '("text", "plotter", "printer")'
setenv D_key13b '"text"'
setenv D_keys13c '("text", "plotter", "printer")'

./expar_test.pl -gxz -int01 145 -int03 7 -str03 string0 -int21 455 -int21 677 \
  -integer47 283 -integer48 234 -integer57 234 -integer58 234324 \
  -integer49 9 -integer50 9 -integer51 9 -integer52 9 -integer53 9 -integer54 9 -integer55 9 -integer56 9 \
  -integer59 9 -integer60 9 -integer61 9 -integer62 9 -integer63 9 -integer64 9 -integer65 9 -integer66 9 \
  -real47 283 -real48 234 -real57 234 -real58 234324 \
  -real49 9.0 -real50 9.0 -real51 9.0 -real52 9.0 -real53 9.0 -real54 9.0 -real55 9.0 -real56 9.0 \
  -real59 9.0 -real60 9.0 -real61 9.0 -real62 9.0 -real63 9.0 -real64 9.0 -real65 9.0 -real66 9.0 \
  -set02 5 6.0 "7.00" -set04 9 10.0 "11.1" \
  -set06 234234 23423.42 "qw5alskdfjq84tu" dk \
  -set06 234234 23423.42 "qw5alskdfjq84tu" ak \
  -key09 plotter -key10 text \
  -set07 45 55.55 "blah" -set07 245 555.55 "blahblah"

