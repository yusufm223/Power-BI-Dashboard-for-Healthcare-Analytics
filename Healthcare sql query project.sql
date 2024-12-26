select * from visits;

alter table visits 
alter column admitted_date date;

select
      *,
      DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
 from visits;
--where discharge_date is not null and admitted_date is not null;


-- 1)Total Medication cost

 select sum(medication_cost) as total_medication_cost from visits;

 -- 2)total Insurance cost

 select round(sum(insurance_coverage),2)  as total_insurance_cost from visits;

 -- 3) total patients

 select count(distinct patient_id) as total_patients from visits;

 -- 4) Total Rooms charges
 
  
 select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
 from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay from visits) as x; 

 -- 5) total treatment 

 select SUM(treatment_cost) as total_treatment_cost from visits;

 -- 6)Total billing amount

 select sum(treatment_cost) + sum(medication_cost) +
			   (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
				from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
				from visits) as x )
 from visits;


 -- 7) out-of-pocket

 select  
         distinct ( select sum(treatment_cost) + sum(medication_cost) +
			   (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
				from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
				from visits) as x )
            from visits) - (select round(sum(insurance_coverage),2)  as total_insurance_cost from visits)
          
from visits;



 -- 8) average medication cost

  select AVG(medication_cost) as avg_medication_cost from visits;

 -- 9) average treatment cost
 
 select avg(treatment_cost) as avg_treatment_cost from visits;

 -- 10) average insurance cost

 select round(avg(insurance_coverage),2) as avg_insurance_cost from visits;

 -- 11) Average room charges

 select 
         
		  (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
		 from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
		 from visits) as x)
		 /
		 count (distinct patient_id) 

from visits;

-- 12) average length of stay

with stay_room as
    (select DATEDIFF(day,admitted_date , discharge_date) as length_of_stay 
	      from visits)

select 
      avg(1.0 * length_of_stay)
from stay_room;

--13)  Average patient satisfactory score

	select avg(1.0 * patient_satisfaction_score) as avg_patinet_satisfaction_score
	from visits;

-- 14) average out of pocket

   select 
           (
		    select  
                distinct ( select sum(treatment_cost) + sum(medication_cost) +
			                (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
				from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
				from visits) as x )
                from visits) - (select round(sum(insurance_coverage),2)  as total_insurance_cost from visits)
            from visits
		   ) / count(distinct patient_id) as avg_out_of_pocket
      
   from visits

-- 15) average billing amount 

 select 
          1.0 * (
		      select sum(treatment_cost) + sum(medication_cost) +
			   (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
				from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
				from visits) as x )
           from visits
		  )/ count(distinct patient_id) as avg_billing_amount
         
from visits;



--16) Total billing amount by city
       
	   
	   with billing_amount as 
	                (
					 select patient_id ,sum(treatment_cost) + sum(medication_cost) +
				        (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
					     from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
					from visits) as x ) as total_billing_cost
				  from visits
				  group by patient_id
				   )    
					
					
	   
	   select city,
	            sum(total_billing_cost) as total_billing_amount      
      from visits v 
	  join billing_amount b on v.Patient_ID = b.Patient_ID
	  join patients p on v.Patient_ID = p.Patient_ID
	  join cities c on p.City_ID = c.City_ID
	  
      group by city
	  order by total_billing_amount desc;

-- Total billing amount by state
 
      with billing_amount as 
	                (
					 select patient_id ,sum(treatment_cost) + sum(medication_cost) +
				        (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
					     from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
					from visits) as x ) as total_billing_cost
				  from visits
				  group by patient_id
				   )    
					
	select state,
	            sum(
					 select sum(treatment_cost) + sum(medication_cost) +
				        (select sum(room_charges_daily_rate * length_of_stay) as total_room_charges
					     from (select room_charges_daily_rate ,DATEDIFF(day,admitted_date , discharge_date) as length_of_stay
					from visits) as x ) as total_billing_cost
				  from visits
				  
				   ) as total_billing_amount      
      from visits v 
	  --join billing_amount b on v.Patient_ID = b.Patient_ID
	  join patients p on v.Patient_ID = p.Patient_ID
	  join cities c on p.City_ID = c.City_ID
	  group by state
	  order by total_billing_amount desc;
