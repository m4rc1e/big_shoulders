# source venv/bin/activate
set -e

mkdir -p ../fonts ../fonts/ttf/Big-Shoulders ../fonts/otf/Big-Shoulders ../fonts/variable ../fonts/woff2/Big-Shoulders

echo "GENERATING TTFs"
fontmake -g Big_Shoulders.glyphs -i -o ttf --output-dir ../fonts/ttf/Big-Shoulders

echo "POST PROCESSING TTFs"
ttfs=$(ls ../fonts/ttf/Big-Shoulders/*.ttf)
for ttf in $ttfs
do
	ttfautohint $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;

    gftools fix-hinting $ttf;
    mv "$ttf.fix" $ttf;

    gftools fix-dsig -f $ttf;
done

echo "GENERATING WOFFs"
ttfs=$(ls ../fonts/ttf/Big-Shoulders/*.ttf)
for ttf in $ttfs; do
    woff2_compress $ttf
done

woff2s=$(ls ../fonts/ttf/Big-Shoulders/*.woff2)
for woff2 in $woff2s; do
    mv $woff2 ../fonts/woff2/Big-Shoulders/$(basename $woff2)
done


echo "GENERATING OTFs"
fontmake -g Big_Shoulders.glyphs -i -o otf --output-dir ../fonts/otf/Big-Shoulders

echo "POST PROCESSING OTFs"
otfs=$(ls ../fonts/otf/Big-Shoulders/*.otf)
for otf in $otfs
do
    gftools fix-dsig -f $otf;
done

echo "GENERATING VFs"
VF_FILE=../fonts/variable/BigShoulders\[opsz,wght]\.ttf
fontmake -g Big_Shoulders.glyphs -o variable --output-path $VF_FILE

rm -rf master_ufo/ instance_ufo/

echo "POST PROCESSING VFs"
ttfautohint $VF_FILE $VF_FILE.fix
mv $VF_FILE.fix $VF_FILE

gftools fix-hinting $VF_FILE
mv $VF_FILE.fix $VF_FILE

gftools fix-dsig -f $VF_FILE

gftools fix-unwanted-tables $VF_FILE -t MVAR

# python3 varta-stat-table2.py $VF_FILE