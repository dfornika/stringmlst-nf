#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { fastp } from './modules/stringmlst.nf'
include { fastp_json_to_csv } from './modules/stringmlst.nf'
include { stringmlst } from './modules/stringmlst.nf'

workflow {

  ch_fastq_input = Channel.fromFilePairs( params.fastq_search_path, flat: true ).filter{ !( it[0] =~ /Undetermined/ ) }.map{ it -> [it[0].split('_')[0], it[1], it[2]] }
  ch_mlst_db = Channel.fromPath( params.db, type: 'dir' )

  main:

  //fastp(ch_fastq)
  //fastp_json_to_csv(fastp.out.fastp_json).map{ it -> it[1] }.collectFile(name:'read_qc.csv', keepHeader: true, sort: { it.text })
  stringmlst(ch_fastq_input.combine(ch_mlst_db))
}
