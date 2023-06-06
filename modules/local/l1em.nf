process L1EM {
    tag "$meta.id"
    label 'process_medium'

    conda "conda-forge::python=2.7.15 bioconda::bwa=0.7.17 bioconda::samtools=1.9 conda-forge::numpy=1.14.3 conda-forge::scipy=1.1.0 bioconda::pysam=0.15.0 bioconda::bedtools=2.27.1"
    container "docker.io/eshajoshi/l1em_test:latest"

    input:
    tuple val(meta), path(bam), path(bai)
    path fasta

    output:
    tuple val(meta), path("full_counts.txt"), emit: full_counts
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    run_L1EM.sh \\
        \$PWD/$bam \\
        L1EM

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$(echo \$(bwa 2>&1) | sed 's/^.*Version: //; s/Contact:.*\$//')
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        bedtools: \$(bedtools --version | sed -e "s/bedtools v//g")
    END_VERSIONS
    """
}
