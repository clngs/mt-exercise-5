#! /bin/bash

scripts=$(dirname "$0")
base=$scripts/..

models=$base/models
configs=$base/configs
codes=$base/codes
vocab=$base/vocab
num_threads=4

# measure time

SECONDS=0

logs=$base/logs

mkdir -p $models
mkdir -p $configs
mkdir -p $codes
mkdir -p $vocab
mkdir -p $logs


TRAIN_FILE_SRC="data/train.sample.it-de.it"
TRAIN_FILE_TRG="data/train.sample.it-de.de"
TRAIN_FILE_CONCAT="data/train.sample.it-de"

OUTPUT_CODES_TEMPLATE="codes/it-de"
VOCAB_FILE_SRC_TEMPLATE="vocab/it-de"
VOCAB_SIZE="2000 100"

model_configs=(
    "transforme_no_bpe_2000_vocab"
    "transformer_bpe_2000_vocab"
    "transformer_bpe_100_vocab"
)

cat $TRAIN_FILE_SRC $TRAIN_FILE_TRG >> $TRAIN_FILE_CONCAT

for vocab_size in $VOCAB_SIZE; do
    echo "Training BPE with $vocab_size vocab size"
    OUTPUT_CODES="$OUTPUT_CODES_TEMPLATE-$vocab_size.bpe"
    VOCAB_FILE="$VOCAB_FILE_SRC_TEMPLATE-$vocab_size.vocab"
    subword-nmt learn-bpe -s $vocab_size -i $TRAIN_FILE_CONCAT -o $OUTPUT_CODES
    echo "BPE with $vocab_size learning done"
    subword-nmt apply-bpe -c $OUTPUT_CODES < $TRAIN_FILE_CONCAT | subword-nmt get-vocab > $VOCAB_FILE
    echo "BPE with $vocab_size vocab size done"
done

# Iterate over each model configuration
for model_config in "${model_configs[@]}"; do
    echo "Training $model_config"
    mkdir -p $logs/$model_config
    OMP_NUM_THREADS=$num_threads python -m joeynmt train "configs/$model_config.yaml" > $logs/$model_config/out 2> $logs/$model_config/err
done