@echo off

echo Creating CSV, please wait...
set PYTHONIOENCODING=utf-8
set IMG_DIR=.\data-download-1
set TAG_MAP=.\map.json
python meta2csv-win.py ".\metadata\photo_*.json" > flickr4.csv


pause
