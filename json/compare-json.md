% compare json
%
% 2022-11-08

Consider we want to compare two big json data (like all ec2 info from 2
different versions of cmdb).

A quick solution is to use vim's diff (like `vim -d 1.json 2.json` then
paste data in two buffers separately);
but the key order may not be same, which causing diff not work.

`jq`'s `-S` option to save: with ex-cmd like `:%!jq -S`, we get proper
indented, key sorted result.

TODO: There may be requirement to treat arrays containing same elements with
different order as equal. Don't know how to do it quickly yet (without
invoking, say, python).
