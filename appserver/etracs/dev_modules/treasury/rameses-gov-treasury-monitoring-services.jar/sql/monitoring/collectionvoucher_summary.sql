[getReportA]
select 
	cast(cv.controldate as date) as controldate, 
	cv.amount, cv.controlno, cv.liquidatingofficer_name 
from collectionvoucher cv  
where cv.controldate >= $P{startdate} 
	and cv.controldate <  $P{enddate} 
	and cv.state = 'POSTED' 
	and ${filter} 
order by cast(cv.controldate as date), cv.liquidatingofficer_name 


[getReportB]
select 
	cast(cv.controldate as date) as controldate, 
	sum(cv.totalcash) as totalcash, sum(cv.totalcheck) as totalcheck, 
	sum(cv.totalcr) as totalcr, sum(cv.amount) as amount 
from collectionvoucher cv 
where cv.controldate >= $P{startdate} 
	and cv.controldate <  $P{enddate} 
	and cv.state = 'POSTED' 
	and ${filter} 
group by cast(cv.controldate as date)
order by cast(cv.controldate as date)


[getReportByFund]
select 
	controldate, sum(amount) as amount, 
	particulars, indexno, fund_objid 
from ( 
	select 
		cast(cv.controldate as date) as controldate, sum(ci.amount) as amount, 
		fund.title as particulars, fg.indexno as indexno, fund.objid as fund_objid 
	from collectionvoucher cv 
		inner join remittance r on r.collectionvoucherid = cv.objid 
		inner join cashreceipt c on c.remittanceid = r.objid 
		inner join cashreceiptitem ci on ci.receiptid = c.objid 
		inner join fund on fund.objid = ci.item_fund_objid 
		inner join fundgroup fg on fg.objid = fund.groupid 
		left join cashreceipt_void v on v.receiptid = c.objid 
	where cv.controldate >= $P{startdate} 
		and cv.controldate <  $P{enddate} 
		and cv.state = 'POSTED' 
		and v.objid is null 
		and ${filter} 
	group by cast(cv.controldate as date), fund.title, fund.objid, fg.indexno
	union all 
	select 
		cast(cv.controldate as date) as controldate, -sum(cs.amount) as amount, 
		fund.title as particulars, fg.indexno as indexno, fund.objid as fund_objid 
	from collectionvoucher cv 
		inner join remittance r on r.collectionvoucherid = cv.objid 
		inner join cashreceipt c on c.remittanceid = r.objid 
		inner join cashreceipt_share cs on cs.receiptid = c.objid 
		inner join itemaccount ia on ia.objid = cs.refitem_objid 
		inner join fund on fund.objid = ia.fund_objid 
		inner join fundgroup fg on fg.objid = fund.groupid 
		left join cashreceipt_void v on v.receiptid = c.objid 
	where cv.controldate >= $P{startdate} 
		and cv.controldate <  $P{enddate} 
		and cv.state = 'POSTED' 
		and v.objid is null 
		and ${filter} 
	group by cast(cv.controldate as date), fund.title, fund.objid, fg.indexno
	union all 
	select 
		cast(cv.controldate as date) as controldate, sum(cs.amount) as amount, 
		fund.title as particulars, fg.indexno as indexno, fund.objid as fund_objid 
	from collectionvoucher cv 
		inner join remittance r on r.collectionvoucherid = cv.objid 
		inner join cashreceipt c on c.remittanceid = r.objid 
		inner join cashreceipt_share cs on cs.receiptid = c.objid 
		inner join itemaccount ia on ia.objid = cs.payableitem_objid
		inner join fund on fund.objid = ia.fund_objid 
		inner join fundgroup fg on fg.objid = fund.groupid 
		left join cashreceipt_void v on v.receiptid = c.objid 
	where cv.controldate >= $P{startdate} 
		and cv.controldate <  $P{enddate} 
		and cv.state = 'POSTED' 
		and v.objid is null 
		and ${filter} 
	group by cast(cv.controldate as date), fund.title, fund.objid, fg.indexno
)t0 
group by controldate, particulars, indexno, fund_objid 
order by controldate, indexno, particulars 


[getReportByLiqOfficer]
select 
	cast(cv.controldate as date) as controldate, 
	sum(cv.amount) as amount, cv.liquidatingofficer_name as particulars 
from collectionvoucher cv 
where cv.controldate >= $P{startdate} 
	and cv.controldate <  $P{enddate} 
	and cv.state = 'POSTED' 
	and ${filter} 
group by cast(cv.controldate as date), cv.liquidatingofficer_name
order by cast(cv.controldate as date), cv.liquidatingofficer_name


[getReportByCollectionType]
select 
	cast(cv.controldate as date) as controldate, sum(c.amount) as amount, 
	c.collectiontype_name as particulars, ct.sortorder as indexno
from collectionvoucher cv 
	inner join remittance r on r.collectionvoucherid = cv.objid 
	inner join cashreceipt c on c.remittanceid = r.objid 
	left join collectiontype ct on ct.objid = c.collectiontype_objid 
	left join cashreceipt_void v on v.receiptid = c.objid 
where cv.controldate >= $P{startdate} 
	and cv.controldate <  $P{enddate} 
	and cv.state = 'POSTED' 
	and v.objid is null 
	and ${filter} 
group by cast(cv.controldate as date), c.collectiontype_name, ct.sortorder
order by cast(cv.controldate as date), ct.sortorder, c.collectiontype_name 
