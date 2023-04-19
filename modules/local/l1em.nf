process L1EM {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::samtools=1.9 bioconda::bedtools=2.27 bioconda::bwa=0.7.17 bioconda::pysam=0.15.0 conda-forge::scipy=1.1.0 conda-forge::numpy=1.14.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-1c6be8ad49e4dfe8ab70558e8fb200d7b2fd7509:5900b4e68c4051137fffd99165b00e98f810acae-0':
        'quay.io/biocontainers/mulled-v2-1c6be8ad49e4dfe8ab70558e8fb200d7b2fd7509:5900b4e68c4051137fffd99165b00e98f810acae-0' }"

    input:
    tuple val(meta), path(bam)
    path l1em_path
    path index

    output:
    tuple val(meta), path('*baminfo.txt')       , emit: bam_info
    tuple val(meta), path('*full_counts.txt')   , emit: counts_full
    tuple val(meta), path('*l1hs_transcript_counts.txt')    , emit: counts_transcript
    tuple val(meta), path('*filter_L1HS_FPM.txt')   , emit: counts_fpm
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p ${prefix}/L1EM
    cd ${prefix}/L1EM/
    run_L1EM.sh \\
        ${prefix}.bam \\
        ${l1em_path} \\
        ${index} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        l1em: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//' ))
    END_VERSIONS
    """
}
