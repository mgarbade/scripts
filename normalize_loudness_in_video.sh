ffmpeg -i input.mkv -af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json" -f null - 2> loudnorm_stats.json


ffmpeg -i input.mkv -af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json" -f null - 2> loudnorm_stats.json


I=-16; TP=-1.5; LRA=11
ffmpeg -i input.mkv -c:v copy -af \
"loudnorm=I=${I}:TP=${TP}:LRA=${LRA}:measured_I=$(jq -r '.input_i' loudnorm_stats.json):measured_LRA=$(jq -r '.input_lra' loudnorm_stats.json):measured_TP=$(jq -r '.input_tp' loudnorm_stats.json):measured_thresh=$(jq -r '.input_thresh' loudnorm_stats.json):offset=$(jq -r '.target_offset' loudnorm_stats.json):linear=true:print_format=summary" \
-c:a aac -b:a 192k output.mkv
