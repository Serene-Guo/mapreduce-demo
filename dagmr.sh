################################
# Author: guofangfang
# mail: guofangfang02@baidu.com
# Created Time: 2016/08/16 17:02:08
#########################################################################

HADOOP_BIN=""



target_url_1="http://www.zhenai.com/901004_1476924.html?keyword=%e6%87%92%e4%ba%ba%e7%9b%b8%e4%ba%b2%61%70%70&kwmatch=e&plan=enc_9a3a7756e68a3aac4b2c0d&group=enc_ac4b7d7c0efc"
search_url_1="http://zhidao.baidu.com/question/1512216162159749900.html"


QUADRANT_HDFS_TMP=${QUADRANT_HDFS}"/"${today}"/"${time_stamp}"/"
seed_cand_map_indir=${QUADRANT_HDFS_TMP}"/find_src_word/seed_cand_map_in/"
bought_map_indir=${QUADRANT_HDFS_TMP}"/find_src_word/bought_map_in/"
word_src_outdir=${QUADRANT_HDFS_TMP}"/find_src_word/word_src_out/"
${HADOOP_BIN} fs -rm ${seed_cand_map_indir}
${HADOOP_BIN} fs -rm ${bought_map_indir}
${HADOOP_BIN} fs -mkdir ${seed_cand_map_indir}
${HADOOP_BIN} fs -mkdir ${bought_map_indir}
${HADOOP_BIN} fs -put "${dest_dir}/seed_word_gid.dat"  ${seed_cand_map_indir}"part1"
if [ $? != 0 ];then
    echo "[qudrant, find word source] put seed word groupid file to hdfs failed"
    exit 1
fi
${HADOOP_BIN} fs -put "${dest_dir}/bought_join_unum.dat" ${bought_map_indir}"part3"
if [ $? != 0 ];then
    echo "[qudrant, find word source] put bought word file to hdfs failed"
    exit 1
fi

${HADOOP_BIN} streaming \
        -input ${seed_cand_map_indir} \
        -output ${word_src_outdir} \
        -mapper "cat" \
        -reducer "cat" \
        -jobconf abaci.is.dag.job=true \
        -jobconf abaci.dag.vertex.num=4 \
        -jobconf abaci.dag.next.vertex.list.0=2 \
        -jobconf abaci.dag.next.vertex.list.1=2 \
        -jobconf abaci.dag.next.vertex.list.2=3 \
        -jobconf mapred.job.map.capacity.0=1500 \
        -jobconf mapred.job.map.capacity.1=1500 \
        -jobconf mapred.job.reduce.capacity.2=1500 \
        -jobconf mapred.job.reduce.capacity.3=1000 \
        -jobconf mapred.reduce.tasks.0=1497\
        -jobconf mapred.reduce.tasks.1=1497 \
        -jobconf mapred.reduce.tasks.2=1497 \
        -jobconf mapred.reduce.tasks.3=1497 \
        -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
        -jobconf mapred.input.dir.0=${seed_cand_map_indir} \
        -jobconf stream.map.streamprocessor.0="python27/bin/python find_word_source.py print_seed_cand" \
        -jobconf stream.num.map.output.key.fields.0=2 \
        -jobconf num.key.fields.for.partition.0=1 \
        -jobconf mapred.input.dir.1=${bought_map_indir} \
        -jobconf stream.map.streamprocessor.1="python27/bin/python find_word_source.py print_bought_words" \
        -jobconf stream.num.map.output.key.fields.1=2 \
        -jobconf num.key.fields.for.partition.1=1 \
        -jobconf stream.reduce.streamprocessor.2="python27/bin/python find_word_source.py split_cand" \
        -jobconf stream.num.reduce.output.key.fields.2=2 \
        -jobconf num.key.fields.for.partition.2=1 \
        -jobconf stream.reduce.streamprocessor.3="python27/bin/python find_word_source.py cal_sim" \
        -cacheArchive "/share/python2.7.tar.gz#python27" \
        -cacheArchive "/app/ecom/fcr/shandian/sicong/tools/word2vec.tar.gz#word2vec" \
        -jobconf mapred.job.priority=VERY_HIGH \
        -jobconf mapred.job.name="quadrant_find_word_source" \
        -file "./bin/find_word_source.py" \
        -file "./bin/ifs_grouper.py" \
        -file "./conf/DFT_ONLINE.conf" \
        -file "./bin/bidword_w2v_sim.py"

