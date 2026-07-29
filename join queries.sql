1.
SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    t.taxpayer_type,
    typ.tax_type_name,
    typ.filing_frequency,
    tc.centre_name,
    tc.district_name,
    SUM(d.declared_amount) AS total_declared_amount,
    SUM(a.assessed_amount) AS total_assessed_amount,
    SUM(p.payment_amount) AS total_payment_amount
FROM TAXPAYER t
INNER JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
INNER JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
INNER JOIN TAX_CENTRE tc ON tr.tax_centre_id = tc.tax_centre_id
INNER JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
INNER JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT p ON a.assessment_id = p.assessment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, t.taxpayer_type, 
         typ.tax_type_name, typ.filing_frequency, 
         tc.centre_name, tc.district_name
HAVING SUM(a.assessed_amount) > 1000000
ORDER BY total_assessed_amount DESC;






2.

SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    t.registration_date AS taxpayer_registration_date,
    typ.tax_type_name,
    tr.registration_date AS tax_registration_date,
    tc.centre_name,
    COUNT(d.declaration_id) AS number_of_declarations,
    SUM(d.declared_amount) AS total_declared_amount
FROM TAXPAYER t
LEFT JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
LEFT JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
LEFT JOIN TAX_CENTRE tc ON tr.tax_centre_id = tc.tax_centre_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, t.registration_date,
         typ.tax_type_name, tr.registration_date, tc.centre_name
HAVING COUNT(d.declaration_id) < 3
ORDER BY number_of_declarations DESC;



3.


SELECT 
    typ.tax_type_id,
    typ.tax_type_name,
    typ.filing_frequency,
    COUNT(DISTINCT tr.taxpayer_id) AS number_of_registered_taxpayers,
    SUM(d.declared_amount) AS total_declared_amount,
    SUM(a.assessed_amount) AS total_assessed_amount
FROM TAX_TYPE typ
LEFT JOIN TAX_REGISTRATION tr ON typ.tax_type_id = tr.tax_type_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
RIGHT JOIN TAX_TYPE typ2 ON typ.tax_type_id = typ2.tax_type_id
GROUP BY typ.tax_type_id, typ.tax_type_name, typ.filing_frequency
HAVING SUM(d.declared_amount) < 5000000
ORDER BY tax_type_id;


4.


SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    b.business_name,
    b.business_sector,
    typ.tax_type_name,
    tc.centre_name,
    SUM(d.declared_amount) AS total_declared_amount,
    SUM(a.assessed_amount) AS total_assessed_amount,
    SUM(p.payment_amount) AS total_payment_amount,
    SUM(pen.penalty_amount) AS total_penalty_amount
FROM TAXPAYER t
INNER JOIN BUSINESS b ON t.taxpayer_id = b.taxpayer_id
INNER JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
INNER JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
INNER JOIN TAX_CENTRE tc ON tr.tax_centre_id = tc.tax_centre_id
INNER JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
INNER JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT p ON a.assessment_id = p.assessment_id
LEFT JOIN PENALTY pen ON a.assessment_id = pen.assessment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, b.business_name, 
         b.business_sector, typ.tax_type_name, tc.centre_name
HAVING SUM(a.assessed_amount) > 10000000
ORDER BY total_assessed_amount DESC;


5.



SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    p.property_location,
    p.property_value,
    COUNT(d.declaration_id) AS number_of_declarations,
    SUM(a.assessed_amount) AS total_assessed_amount,
    SUM(pay.payment_amount) AS total_payment_amount
FROM PROPERTY p
LEFT JOIN TAXPAYER t ON p.taxpayer_id = t.taxpayer_id
LEFT JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT pay ON a.assessment_id = pay.assessment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, p.property_location, p.property_value
HAVING SUM(pay.payment_amount) = 0 
   OR SUM(pay.payment_amount) < SUM(a.assessed_amount)
ORDER BY property_value DESC;


6.


SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    v.plate_number,
    v.vehicle_value,
    typ.tax_type_name,
    COUNT(d.declaration_id) AS number_of_declarations,
    SUM(d.declared_amount) AS total_declared_amount,
    SUM(a.assessed_amount) AS total_assessed_amount,
    SUM(pen.penalty_amount) AS total_penalties
FROM VEHICLE v
LEFT JOIN TAXPAYER t ON v.taxpayer_id = t.taxpayer_id
LEFT JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
LEFT JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN PENALTY pen ON a.assessment_id = pen.assessment_id
RIGHT JOIN VEHICLE v2 ON v.vehicle_id = v2.vehicle_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, v.plate_number, 
         v.vehicle_value, typ.tax_type_name
HAVING v.vehicle_value > 10000000
ORDER BY vehicle_value DESC;



7.





SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    typ.tax_type_name,
    tp.period_start_date,
    tp.period_end_date,
    tp.filing_due_date,
    COUNT(d.declaration_id) AS number_of_declarations,
    SUM(d.declared_amount) AS total_declared_amount,
    SUM(a.assessed_amount) AS total_assessed_amount,
    SUM(pay.payment_amount) AS total_amount_paid,
    (SUM(a.assessed_amount) - SUM(pay.payment_amount)) AS outstanding_balance
FROM TAXPAYER t
INNER JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
INNER JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
INNER JOIN TAX_PERIOD tp ON typ.tax_type_id = tp.tax_type_id
INNER JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id 
    AND tp.tax_period_id = d.tax_period_id
INNER JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT pay ON a.assessment_id = pay.assessment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, typ.tax_type_name,
         tp.period_start_date, tp.period_end_date, tp.filing_due_date
HAVING (SUM(a.assessed_amount) - SUM(pay.payment_amount)) > 0
ORDER BY outstanding_balance DESC;

8.



SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    ta.audit_status,
    tof.officer_name,
    tc.centre_name,
    typ.tax_type_name,
    COUNT(af.finding_id) AS number_of_audit_findings,
    SUM(af.finding_amount) AS total_finding_amount
FROM TAX_AUDIT ta
LEFT JOIN TAXPAYER t ON ta.taxpayer_id = t.taxpayer_id
LEFT JOIN TAX_OFFICER tof ON ta.officer_id = tof.officer_id
LEFT JOIN TAX_CENTRE tc ON tof.tax_centre_id = tc.tax_centre_id
LEFT JOIN AUDIT_FINDING af ON ta.audit_id = af.audit_id
LEFT JOIN TAX_TYPE typ ON af.tax_type_id = typ.tax_type_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, ta.audit_status,
         tof.officer_name, tc.centre_name, typ.tax_type_name
HAVING SUM(af.finding_amount) > 2000000
ORDER BY total_finding_amount DESC;


9.


SELECT 
    tof.officer_id,
    tof.officer_name,
    tof.officer_position,
    tc.centre_name,
    tc.district_name,
    COUNT(DISTINCT ta.audit_id) AS number_of_audits,
    SUM(af.finding_amount) AS total_audit_finding_amount,
    AVG(af.finding_amount) AS avg_finding_amount
FROM TAX_OFFICER tof
LEFT JOIN TAX_AUDIT ta ON tof.officer_id = ta.officer_id
LEFT JOIN AUDIT_FINDING af ON ta.audit_id = af.audit_id
LEFT JOIN TAX_CENTRE tc ON tof.tax_centre_id = tc.tax_centre_id
RIGHT JOIN TAX_OFFICER tof2 ON tof.officer_id = tof2.officer_id
GROUP BY tof.officer_id, tof.officer_name, tof.officer_position,
         tc.centre_name, tc.district_name
HAVING AVG(af.finding_amount) > 500000
ORDER BY avg_finding_amount DESC;


10.


SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    a.assessment_id,
    a.assessment_date,
    a.assessed_amount,
    obj.objection_status,
    SUM(p.payment_amount) AS total_payment_amount,
    SUM(pen.penalty_amount) AS total_penalty_amount
FROM TAXPAYER t
INNER JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
INNER JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
INNER JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
INNER JOIN TAX_OBJECTION obj ON a.assessment_id = obj.assessment_id
LEFT JOIN TAX_PAYMENT p ON a.assessment_id = p.assessment_id
LEFT JOIN PENALTY pen ON a.assessment_id = pen.assessment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, a.assessment_id, 
         a.assessment_date, a.assessed_amount, obj.objection_status
HAVING COUNT(DISTINCT obj.objection_id) >= 1
   AND SUM(pen.penalty_amount)> 100000
ORDER BY total_penalty_amount DESC;


11.

SELECT
t.taxpayer_tin,
t.taxpayer_name,
a.assessment_id,
a.assessed_amount,
 COUNT(obj.objection_id) AS number_of_objections,
 COALESCE(SUM(p.payment_amount), 0) AS total_payment_amount,
 a.assessed_amount - COALESCE(SUM(p.payment_amount), 0) AS outstanding_balance
 FROM TAX_ASSESSMENT a
 LEFT JOIN TAX_DECLARATION d ON a.declaration_id = d.declaration_id
 LEFT JOIN TAX_REGISTRATION tr ON d.registration_id = tr.registration_id
 LEFT JOIN TAXPAYER t ON tr.taxpayer_id = t.taxpayer_id
 LEFT JOIN TAX_OBJECTION obj ON a.assessment_id = obj.assessment_id
 LEFT JOIN TAX_PAYMENT p ON a.assessment_id = p.assessment_id
 GROUP BY 
 t.taxpayer_tin, 
 t.taxpayer_name, 
 a.assessment_id, 
 a.assessed_amount
HAVING (a.assessed_amount - COALESCE(SUM(p.payment_amount), 0)) > 500000;



12.



SELECT 
    b.bank_id,
    b.bank_name,
    b.bank_code,
    b.branch_name,
    COUNT(p.payment_id) AS number_of_payments,
    COALESCE(SUM(p.payment_amount), 0) AS total_payment_amount,
    AVG(p.payment_amount) AS average_payment_amount,
    MAX(p.payment_amount) AS maximum_payment_amount,
    MIN(p.payment_amount) AS minimum_payment_amount
FROM BANK b
LEFT JOIN TAX_PAYMENT p ON b.bank_id = p.bank_id
RIGHT JOIN BANK b2 ON b.bank_id = b2.bank_id
GROUP BY b.bank_id, b.bank_name, b.bank_code, b.branch_name
HAVING COALESCE(SUM(p.payment_amount), 0) < 20000000
ORDER BY total_payment_amount DESC;


13.





SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    p.payment_date,
    b.bank_name,
    typ.tax_type_name,
    COUNT(p.payment_id) AS number_of_payments,
    SUM(p.payment_amount) AS total_payment_amount,
    COALESCE(SUM(ref.refund_amount), 0) AS total_refund_amount,
    (SUM(p.payment_amount) - COALESCE(SUM(ref.refund_amount), 0)) AS net_revenue_collected
FROM TAXPAYER t
INNER JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
INNER JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
INNER JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
INNER JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
INNER JOIN TAX_PAYMENT p ON a.assessment_id = p.assessment_id
INNER JOIN BANK b ON p.bank_id = b.bank_id
LEFT JOIN TAX_REFUND ref ON p.payment_id = ref.payment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, p.payment_date, 
         b.bank_name, typ.tax_type_name
HAVING (SUM(p.payment_amount) - COALESCE(SUM(ref.refund_amount), 0)) > 1000000
ORDER BY net_revenue_collected DESC;

14.






SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    p.payment_id,
    p.payment_amount,
    COALESCE(r.refund_amount, 0) AS refund_amount,
    r.refund_date,
    ROUND(COALESCE(r.refund_amount / p.payment_amount * 100, 0), 2) AS refund_percentage
FROM TAX_PAYMENT p
LEFT JOIN TAX_REFUND r ON p.payment_id = r.payment_id
LEFT JOIN TAX_ASSESSMENT a ON p.assessment_id = a.assessment_id
LEFT JOIN TAX_DECLARATION d ON a.declaration_id = d.declaration_id
LEFT JOIN TAX_REGISTRATION tr ON d.registration_id = tr.registration_id
LEFT JOIN TAXPAYER t ON tr.taxpayer_id = t.taxpayer_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, p.payment_id, 
         p.payment_amount, r.refund_amount, r.refund_date
HAVING ROUND(COALESCE(r.refund_amount / p.payment_amount * 100, 0), 2) > 10
ORDER BY refund_percentage DESC;



15.

SELECT 
    tc.tax_centre_id,
    tc.centre_name,
    tc.district_name,
    tc.centre_manager,
    typ.tax_type_name,
    rt.target_year,
    rt.target_amount,
    COALESCE(SUM(d.declared_amount), 0) AS total_declared_amount,
    COALESCE(SUM(a.assessed_amount), 0) AS total_assessed_amount,
    COALESCE(SUM(p.payment_amount), 0) AS total_revenue_collected
FROM REVENUE_TARGET rt
LEFT JOIN TAX_CENTRE tc ON rt.tax_centre_id = tc.tax_centre_id
LEFT JOIN TAX_TYPE typ ON rt.tax_type_id = typ.tax_type_id
LEFT JOIN TAX_REGISTRATION tr ON typ.tax_type_id = tr.tax_type_id 
    AND tc.tax_centre_id = tr.tax_centre_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT p ON a.assessment_id = p.assessment_id
RIGHT JOIN REVENUE_TARGET rt2 ON rt.target_id = rt2.target_id
GROUP BY tc.tax_centre_id, tc.centre_name, tc.district_name, tc.centre_manager,
         typ.tax_type_name, rt.target_year, rt.target_amount
HAVING COALESCE(SUM(p.payment_amount), 0) < rt.target_amount
ORDER BY (rt.target_amount - COALESCE(SUM(p.payment_amount), 0)) DESC;



16.



SELECT 
    tof.officer_id,
    tof.officer_name,
    tof.officer_position,
    tc.centre_name,
    COUNT(DISTINCT a.assessment_id) AS number_of_assessments,
    COALESCE(SUM(a.assessed_amount), 0) AS total_assessed_amount,
    COUNT(DISTINCT tau.audit_id) AS number_of_audits,
    COALESCE(SUM(af.finding_amount), 0) AS total_audit_finding_amount,
    COUNT(DISTINCT ec.enforcement_id) AS number_of_enforcement_cases,
    COALESCE(SUM(ec.outstanding_amount), 0) AS total_enforcement_outstanding_amount
FROM TAX_OFFICER tof
INNER JOIN TAX_CENTRE tc ON tof.tax_centre_id = tc.tax_centre_id
LEFT JOIN TAX_ASSESSMENT a ON tof.officer_id = a.officer_id
LEFT JOIN TAX_AUDIT tau ON tof.officer_id = tau.officer_id
LEFT JOIN AUDIT_FINDING af ON tau.audit_id = af.audit_id
LEFT JOIN ENFORCEMENT_CASE ec ON tof.officer_id = ec.officer_id
GROUP BY tof.officer_id, tof.officer_name, tof.officer_position, tc.centre_name
HAVING COUNT(DISTINCT a.assessment_id) > 5
   AND COALESCE(SUM(ec.outstanding_amount), 0) > 1000000
ORDER BY total_enforcement_outstanding_amount DESC;


17.


SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    COUNT(DISTINCT b.business_id) AS number_of_businesses,
    COUNT(DISTINCT p.property_id) AS number_of_properties,
    COUNT(DISTINCT v.vehicle_id) AS number_of_vehicles,
    COALESCE(SUM(p.property_value), 0) AS total_property_value,
    COALESCE(SUM(v.vehicle_value), 0) AS total_vehicle_value,
    COUNT(DISTINCT d.declaration_id) AS number_of_declarations,
    COALESCE(SUM(a.assessed_amount), 0) AS total_assessed_amount,
    COALESCE(SUM(pay.payment_amount), 0) AS total_payment_amount,
    COALESCE(SUM(rf.refund_amount), 0) AS total_refund_amount
FROM TAXPAYER t
LEFT JOIN BUSINESS b ON t.taxpayer_id = b.taxpayer_id
LEFT JOIN PROPERTY p ON t.taxpayer_id = p.taxpayer_id
LEFT JOIN VEHICLE v ON t.taxpayer_id = v.taxpayer_id
LEFT JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT pay ON a.assessment_id = pay.assessment_id
LEFT JOIN TAX_REFUND rf ON pay.payment_id = rf.payment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name
HAVING (COALESCE(SUM(p.property_value), 0) + COALESCE(SUM(v.vehicle_value), 0)) > 50000000
ORDER BY (COALESCE(SUM(p.property_value), 0) + COALESCE(SUM(v.vehicle_value), 0)) DESC;


18.




SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    b.business_sector,
    COUNT(DISTINCT b.business_id) AS number_of_businesses,
    COUNT(DISTINCT p.property_id) AS number_of_properties,
    COUNT(DISTINCT v.vehicle_id) AS number_of_vehicles,
    COALESCE(SUM(d.declared_amount), 0) AS total_declared_amount,
    COALESCE(SUM(a.assessed_amount), 0) AS total_assessed_amount,
    COALESCE(SUM(pay.payment_amount), 0) AS total_payment_amount,
    COALESCE(SUM(pen.penalty_amount), 0) AS total_penalty_amount,
    COALESCE(SUM(af.finding_amount), 0) AS total_audit_finding_amount
FROM BUSINESS b
LEFT JOIN TAXPAYER t ON b.taxpayer_id = t.taxpayer_id
LEFT JOIN PROPERTY p ON t.taxpayer_id = p.taxpayer_id
LEFT JOIN VEHICLE v ON t.taxpayer_id = v.taxpayer_id
LEFT JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_PAYMENT pay ON a.assessment_id = pay.assessment_id
LEFT JOIN PENALTY pen ON a.assessment_id = pen.assessment_id
LEFT JOIN TAX_AUDIT tau ON t.taxpayer_id = tau.taxpayer_id
LEFT JOIN AUDIT_FINDING af ON tau.audit_id = af.audit_id
RIGHT JOIN BUSINESS b2 ON b.business_id = b2.business_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, b.business_sector
HAVING (COUNT(DISTINCT p.property_id) + COUNT(DISTINCT v.vehicle_id)) > 1
ORDER BY (COUNT(DISTINCT p.property_id) + COUNT(DISTINCT v.vehicle_id)) DESC;



19.


SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    typ.tax_type_name,
    tc.centre_name,
    tp.period_start_date,
    tp.period_end_date,
    tp.filing_due_date,
    SUM(CASE 
        WHEN d.declaration_date > tp.filing_due_date THEN 1 
        ELSE 0 
    END) AS number_of_late_declarations,
    SUM(d.declared_amount) AS total_declared_amount,
    SUM(a.assessed_amount) AS total_assessed_amount,
    COALESCE(SUM(pen.penalty_amount), 0) AS total_penalty_amount,
    COALESCE(SUM(pay.payment_amount), 0) AS total_payment_amount
FROM TAXPAYER t
INNER JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
INNER JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
INNER JOIN TAX_CENTRE tc ON tr.tax_centre_id = tc.tax_centre_id
INNER JOIN TAX_PERIOD tp ON typ.tax_type_id = tp.tax_type_id
INNER JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id 
    AND tp.tax_period_id = d.tax_period_id
INNER JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN PENALTY pen ON a.assessment_id = pen.assessment_id
LEFT JOIN TAX_PAYMENT pay ON a.assessment_id = pay.assessment_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, typ.tax_type_name, tc.centre_name,
         tp.period_start_date, tp.period_end_date, tp.filing_due_date
HAVING SUM(CASE 
        WHEN d.declaration_date > tp.filing_due_date THEN 1 
        ELSE 0 
    END) > 1
ORDER BY number_of_late_declarations DESC;







20.








SELECT 
    t.taxpayer_tin,
    t.taxpayer_name,
    t.taxpayer_type,
    b.business_name,
    p.property_location,
    v.plate_number,
    typ.tax_type_name,
    typ.filing_frequency,
    tc.centre_name,
    tc.district_name,
    tof.officer_name,
    bank.bank_name,
    COUNT(DISTINCT d.declaration_id) AS number_of_declarations,
    COALESCE(SUM(d.declared_amount), 0) AS total_declared_amount,
    COALESCE(SUM(a.assessed_amount), 0) AS total_assessed_amount,
    COALESCE(SUM(pay.payment_amount), 0) AS total_payment_amount,
    COALESCE(SUM(pen.penalty_amount), 0) AS total_penalty_amount,
    COALESCE(SUM(af.finding_amount), 0) AS total_audit_finding_amount,
    COALESCE(SUM(rf.refund_amount), 0) AS total_refund_amount,
    COALESCE(SUM(ec.outstanding_amount), 0) AS total_enforcement_outstanding_amount,
    rt.target_amount,
    ROUND(COALESCE(SUM(pay.payment_amount) / NULLIF(rt.target_amount, 0) * 100, 0), 2) AS revenue_performance_percentage
FROM TAXPAYER t
LEFT JOIN BUSINESS b ON t.taxpayer_id = b.taxpayer_id
LEFT JOIN PROPERTY p ON t.taxpayer_id = p.taxpayer_id
LEFT JOIN VEHICLE v ON t.taxpayer_id = v.taxpayer_id
LEFT JOIN TAX_REGISTRATION tr ON t.taxpayer_id = tr.taxpayer_id
LEFT JOIN TAX_TYPE typ ON tr.tax_type_id = typ.tax_type_id
LEFT JOIN TAX_CENTRE tc ON tr.tax_centre_id = tc.tax_centre_id
LEFT JOIN TAX_PERIOD tp ON typ.tax_type_id = tp.tax_type_id
LEFT JOIN TAX_DECLARATION d ON tr.registration_id = d.registration_id 
    AND tp.tax_period_id = d.tax_period_id
LEFT JOIN TAX_ASSESSMENT a ON d.declaration_id = a.declaration_id
LEFT JOIN TAX_OFFICER tof ON a.officer_id = tof.officer_id
LEFT JOIN TAX_PAYMENT pay ON a.assessment_id = pay.assessment_id
LEFT JOIN BANK bank ON pay.bank_id = bank.bank_id
LEFT JOIN PENALTY pen ON a.assessment_id = pen.assessment_id
LEFT JOIN TAX_AUDIT tau ON t.taxpayer_id = tau.taxpayer_id
LEFT JOIN AUDIT_FINDING af ON tau.audit_id = af.audit_id
LEFT JOIN TAX_REFUND rf ON pay.payment_id = rf.payment_id
LEFT JOIN ENFORCEMENT_CASE ec ON t.taxpayer_id = ec.taxpayer_id
LEFT JOIN REVENUE_TARGET rt ON tc.tax_centre_id = rt.tax_centre_id 
    AND typ.tax_type_id = rt.tax_type_id
GROUP BY t.taxpayer_tin, t.taxpayer_name, t.taxpayer_type, 
         b.business_name, p.property_location, v.plate_number,
         typ.tax_type_name, typ.filing_frequency, tc.centre_name, 
         tc.district_name, tof.officer_name, bank.bank_name, rt.target_amount
HAVING COALESCE(SUM(a.assessed_amount), 0) > COALESCE(SUM(d.declared_amount), 0)
   AND COALESCE(SUM(pay.payment_amount), 0) > 0
   AND COALESCE(SUM(ec.outstanding_amount), 0) > 0
ORDER BY revenue_performance_percentage DESC;
