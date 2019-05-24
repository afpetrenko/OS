#!/bin/bash
for file in destination/*.log; do mv ./$file ./$file.back; done && mv source/*.log destination/
exit
ls