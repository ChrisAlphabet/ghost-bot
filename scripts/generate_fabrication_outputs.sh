#!/bin/bash

kicad-cli --version

ROOT_DIR=$(git rev-parse --show-toplevel)
pushd "$ROOT_DIR"

SOURCE_DIR=$ROOT_DIR/pcb
OUTPUT_DIR=$ROOT_DIR/pcb/output

if [ -d "$OUTPUT_DIR" ]; then rm -rf $OUTPUT_DIR; fi
mkdir -p "$OUTPUT_DIR"/gerbers "$OUTPUT_DIR"/drill "$OUTPUT_DIR"/step "$OUTPUT_DIR"/docs

# generate drc
kicad-cli pcb drc --output="$OUTPUT_DIR"/docs/ghost-bot-drc.json --format=json --all-track-errors --schematic-parity --units=mm --severity-all --exit-code-violations "$SOURCE_DIR"/ghost-bot.kicad_pcb
kicad-cli pcb drc --output="$OUTPUT_DIR"/docs/ghost-bot-drc.rpt --format=report --all-track-errors --schematic-parity --units=mm --severity-all --exit-code-violations "$SOURCE_DIR"/ghost-bot.kicad_pcb

# generate gerber files for jlc-pcb, see # https://jlcpcb.com/help/article/362-how-to-generate-gerber-and-drill-files-in-kicad-7 for options
kicad-cli pcb export gerbers --output="$OUTPUT_DIR"/gerbers/ --layers="F.Cu,F.Paste,F.Silkscreen,F.Mask,B.Cu,B.Paste,B.Silkscreen,B.Mask,Edge.Cuts" --subtract-soldermask --exclude-value --no-x2 --no-netlist "$SOURCE_DIR"/ghost-bot.kicad_pcb

# generate drill file for jlc-pcb
kicad-cli pcb export drill --output="$OUTPUT_DIR"/drill/ --format=excellon --drill-origin=absolute --excellon-zeros-format=decimal --excellon-units=mm --excellon-oval-format=alternate --generate-map --map-format=gerberx2 "$SOURCE_DIR"/ghost-bot.kicad_pcb

# generate step file
kicad-cli pcb export step --drill-origin --subst-models --force --min-distance=0.01mm --output="$OUTPUT_DIR"/step/ghost-bot.step "$SOURCE_DIR"/ghost-bot.kicad_pcb

# generate pcb pdf
kicad-cli pcb export pdf --output="$OUTPUT_DIR"/docs/ghost-bot-pcb.pdf --include-border-title --layers="B.Cu,B.Paste,B.Silkscreen,B.Mask,F.Cu,F.Paste,F.Silkscreen,F.Mask,Edge.Cuts" "$SOURCE_DIR"/ghost-bot.kicad_pcb

# generate schematic pdf
kicad-cli sch export pdf --output="$OUTPUT_DIR"/docs/ghost-bot-schematic.pdf "$SOURCE_DIR"/ghost-bot.kicad_sch

# generate bom
kicad-cli sch export bom --output="$OUTPUT_DIR"/docs/ghost-bot-bom.csv --format-preset=CSV --field-delimiter="," "$SOURCE_DIR"/ghost-bot.kicad_sch
