process fastp {

  tag { sample_id }

  input:
  tuple val(grouping_key), path(reads)

  output:
  tuple val(sample_id), path("${sample_id}_fastp.json"), emit: fastp_json
  tuple val(sample_id), path("${sample_id}_trimmed_R1.fastq.gz"), path("${sample_id}_trimmed_R2.fastq.gz"), emit: reads

  script:
  if (grouping_key =~ '_S[0-9]+_') {
    sample_id = grouping_key.split("_S[0-9]+_")[0]
  } else if (grouping_key =~ '_') {
    sample_id = grouping_key.split("_")[0]
  } else {
    sample_id = grouping_key
  }
  """
  fastp -i ${reads[0]} -I ${reads[1]} -o ${sample_id}_trimmed_R1.fastq.gz -O ${sample_id}_trimmed_R2.fastq.gz
  mv fastp.json ${sample_id}_fastp.json
  """
}

process fastp_json_to_csv {

  tag { sample_id }

  executor 'local'

  input:
  tuple val(sample_id), path(fastp_json)

  output:
  tuple val(sample_id), path("${sample_id}_read_count.csv")

  script:
  """
  fastp_json_to_csv.py -s ${sample_id} ${fastp_json} > ${sample_id}_read_count.csv
  """
}

process stringmlst {

    tag { sample_id }
    
    cpus 1

    publishDir "${params.outdir}", mode: 'copy', pattern: "${sample_id}_mlst.tsv"

    input:
    tuple val(sample_id), path(reads_1), path(reads_2), path(db)

    output:
    tuple val(sample_id), path("${sample_id}_mlst.tsv")
    
    script:
    """
    stringMLST.py --predict -1 ${reads_1} -2 ${reads_2} -k ${params.kmer_size} -P ${db}/${params.db_prefix} > ${sample_id}_mlst.tsv
    """
}