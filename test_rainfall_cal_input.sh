#!/bin/bash

echo "================================================================================="
echo "################ Wellcome to Rainfall calculate program #######################"
echo "================================================================================="

echo "Please input calculate type follow below."
echo "Agency: [ haii bma dnp dwr hd tmd egat ]  or Download ID: [ download_id ]"
echo ""
echo "Ex1.haii bma dnp dwr hd tmd egat"
echo "Ex2.download_id"
echo "================================================================================="
echo -n "Please input :"
read -a AGENCY #หน่วยงาน หรือ download id

if [ "$AGENCY" != "download_id" ]; then

	#แสดงรายการประเภทฝนที่ใช้ในการคำนวนให้ผุ้ใช้งานเลือก
	echo "================================================================================="
	echo "Rainfall type"
	echo "[0]: rainfall1h"
	echo "[1]: rainfall24h"
	echo "[2]: rainfall_today"
	echo "[3]: rainfall_daily"
	echo "[4]: rainfall_monthly"
	echo "[5]: rainfall_yearly"
	echo "================================================================================="

	echo -n "Please input rainfall:"
	read -a INDEX #ประเภทของฝนที่จะคำนวน

	#กตรวจสอบ้อมูลประเภทฝน
	if [ $INDEX -lt 0 ]; then
			echo "Invalid rainfall type! please input number 0-5 only"
			exit 0
	fi
	
	if [ $INDEX -gt 5 ]; then
			echo "Invalid rainfall type! please input number 0-5 only"
			exit 0
	fi

	#เตรียมข้อมูล Download id ตามหน่วยงานและประเภทฝนที่เลือก
	for ag in "${AGENCY[@]}"
	do
		#echo "Agency : "$ag
		if [ "$ag" == "haii" ]; then
			#echo "Run Rainfall HAII"
			#DOWNLOAD_ID(1H 24H TODAY DAILY MONTHLY YEARLY)
			DOWNLOAD_ID=(315 510 511 512 513 514)

		elif [ "$ag" == "bma" ]; then
			#echo "Run Rainfall BMA"
			DOWNLOAD_ID=(515 516 517 518 519 520)

		elif [ "$ag" == "dnp" ]; then
			#echo "Run Rainfall DNP"
			DOWNLOAD_ID=(521 522 531 532 571 572)

		elif [ "$ag" == "dwr" ]; then
			#echo "Run Rainfall DWR"
			DOWNLOAD_ID=(523 524 534 535 529 533)

		elif [ "$ag" == "hd" ]; then
			#echo "Run Rainfall HD"
			DOWNLOAD_ID=(525 526 536 537 null null)

		elif [ "$ag" == "tmd" ]; then
			#echo "Run Rainfall TMD"
			DOWNLOAD_ID=(527 528 540 564 541 542)

		elif [ "$ag" == "egat" ]; then
			#echo "Run Rainfall EGAT"
			DOWNLOAD_ID=(618 619 null null null null)
		else
			echo "Invalid Agency!"
			exit 0
		fi

		for i in "${INDEX[@]}"
		do
			if [ "${DOWNLOAD_ID[$i]}" != null ]; then
				# if [ "$i" == 4 ]; then
				# 	DL+=("M"${DOWNLOAD_ID[$i]})
				# elif [ "$i" == 5 ]; then
				# 	DL+=("Y"${DOWNLOAD_ID[$i]})
				# else 
					DL+=(${DOWNLOAD_ID[$i]})
				#fi
			fi
		done #end loop
	done #end loop
else
	echo -n "Download id:"
	read -a DL #download id ที่ได้จากผู้ใช้งานกรอกผ่านหน้าจอ
	reCheck=true
fi

echo -n "Start Date(YYYY-MM-DD):"
read -a STDATE #วันที่เริ่มคำนวน

echo -n "End Date(YYYY-MM-DD):"
read -a ENDATE #วันสุดท้ายที่คำนวน

DULATION=$(($(date -d $ENDATE "+%s") - $(date -d $STDATE "+%s")))

#ตรวจสอบความถูกต้องของวันที่กรอกจากหน้าจอ
if [ "$DULATION" -lt 0 ]; then
	echo "Invalid date!"
	exit 0
fi

echo "================================================================================="

#เช็คหน่วยงานบางตัวไม่มีข้อมูลฝน
if [ "$DL" == "" ]; then
	echo "There isn't this data to calculate"
fi


#แยกประเภทการคำนวนตามประเภทของฝนหรือตาม download id
for dl in "${DL[@]}"
do
	echo "Download id :" $dl
	if [ "$dl" == 513 ] || [ "$dl" == 519 ] || [ "$dl" == 571 ] || [ "$dl" == 529 ] || [ "$dl" == 541 ]; then
		dl="M"$dl
	fi

	if [ "$dl" == 514 ] || [ "$dl" == 520 ] || [ "$dl" == 572 ] || [ "$dl" == 533 ] || [ "$dl" == 542 ]; then
		dl="Y"$dl
	fi

	TPYERAIN=${dl:0:1} #เช็คว่า Download ID ที่ส่งมาเป็นของ monthly(ขึ้นต้นด้วย M) หรือ yearly(ขึ้นต้นด้วย Y) หรือไม่?
	#echo $TPYERAIN

	DIFFDATE=$(($DULATION / 86400)) #จำนวนวันที่ได้จากการรับค่า

	if [ "$TPYERAIN" == "Y" ]; then
	#คำนวนฝนรายปี Yearly
		echo "#####  Rainfall Yearly!  #####"
		#STDATE=2018-01-01
		#ENDATE=2022-01-01
		#DOWNLOAD_ID=Y514
		STYEAR="${STDATE:0:4}" #2018
		ENYEAR="${ENDATE:0:4}" #2022
		DOWNID=$(echo $dl | cut -c 2-) #Download ID Ex.514

		#รันคำสั่งตามจำนวนปี
		for (( d=$STYEAR; d<=$ENYEAR; d++ ))
		do
			#TW30_PQTRANSFORM_REPLACE_VALUE1=$DATE bin/rdl $dl dl-basic
			echo "TW30_PQTRANSFORM_REPLACE_VALUE1="$d"-01-01 bin/rdl "$DOWNID" dl-basic" #คำสั่งคำนวนฝน
		done
	elif [ "$TPYERAIN" == "M" ]; then
	#คำนวนฝนรายเดือน Monthly
		echo "#####  Rainall Monthly!  #####"

		#STDATE=2018-01-01
		#ENDATE=2022-01-01		
		#DOWNLOAD_ID=M514
		STMONTH="${STDATE:0:4}""${STDATE:5:2}" #201801
		ENMONTH="${ENDATE:0:4}""${ENDATE:5:2}" #202201	
		DOWNID=$(echo $dl | cut -c 2-) #Download ID Ex.514

		#รันคำสั่งตามจำนวนเดือน
		for (( d=$STMONTH; d<=$ENMONTH; d++ ))
		do
			Y="${d:0:4}" #ปี Ex.2018
			M="${d:4:2}" #เดือน Ex.01

			#TW30_PQTRANSFORM_REPLACE_VALUE1=$DATE bin/rdl $dl dl-basic
			echo "TW30_PQTRANSFORM_REPLACE_VALUE1="$Y"-"$M"-01 bin/rdl "$DOWNID" dl-basic" #คำสั่งคำนวนฝน

			#เริ่มปีถัดไปเมื่อถึงเดือนที่ 12 
			if [ "$M" == 12 ]; then
				d=$d+88
			fi
		done
	else	
	#คำนวนฝนที่ไม่ใช่ Monthly และ Yearly
		for i in `seq 0 $DIFFDATE`
		do
			DATE="$(date -d $STDATE'+'$i' day' '+%Y-%m-%d')" #Next date and format
			#TW30_PQTRANSFORM_REPLACE_VALUE1=$DATE bin/rdl $dl dl-basic
			echo "TW30_PQTRANSFORM_REPLACE_VALUE1="$DATE" bin/rdl "$dl" dl-basic"
		done
	fi

	echo "================================================================================="

done

                                  