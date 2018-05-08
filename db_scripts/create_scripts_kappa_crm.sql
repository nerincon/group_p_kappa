-- CREATE DATABASE kappa
-- change database to kappa

CREATE SCHEMA crm;

CREATE TABLE crm.employee (
	-- populated internally
	id	serial PRIMARY KEY,
	first_name	varchar(50)	NOT NULL,
	last_name	varchar(50)	NOT NULL,
	birthdate	date	NOT NULL,
	gender	char(1)	NOT NULL,
	-- gender 'M = male, F = female, O = other'
	email	varchar(50)	NOT NULL,
	phone	bigint	NOT NULL,
	active_flag	BOOLEAN	NOT NULL DEFAULT TRUE,
	user_id int NOT NULL,
	-- user_id comes from security.users.id
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.customer (
-- populated by client facing quote page and back office employee entry
	id	serial PRIMARY KEY,
	primary_agent_id	int	NULL REFERENCES crm.employee(id),
	first_name	varchar(50)	NOT NULL,
	last_name	varchar(50)	NOT NULL,
	birthdate	date	NULL,
	gender	char(1)	NULL,
	-- gender 'M = male, F = female, O = other'
	marital_status	varchar(15)	NULL,
	-- marital_status 'Single, Married' etc
	occupation	varchar(255)	NULL,
	email	varchar(255)	NULL,
	phone	bigint	NULL,
	id_type	varchar(30)	NULL,
	-- id_type 'Texas Drivers License, Texas ID, Out of state, Passport, Matricula, International Drivers License, No ID'
	id_number	varchar(30)	NULL,
	address	varchar(255)	NULL,
	city	varchar(50)	NULL,
	state	char(2)	NULL,
	zip	int	NULL,
	pref_language	char(15)	NULL DEFAULT 'English',
	customer_rating	smallint	NULL CHECK (customer_rating between 1 and 5) DEFAULT 5,
	homeowner_flag	BOOLEAN	NULL,
	-- homeowner_flag comes from discount page
	curr_insured_flag	BOOLEAN	NULL,
	-- curr_insured_flag comes from discount page
	curr_insured_duration	varchar(30)	NULL,
	-- curr_insured_duration 'Less than 6 months, 6 to 11 months, 12 months or longer'
	-- curr_insured_duration comes from discount page
	curr_carrier	varchar(255)	NULL,
	-- curr_carrier comes from discount page
	accident_tickets_flag	BOOLEAN	NULL,
	-- accident_tickets_flag comes from points page
	num_accidents	int	NULL,
	-- num_accidents comes from points page
	num_tickets	int	NULL,
	-- num_tickets comes from points page
	at_fault_flag	BOOLEAN	NULL,
	-- at_fault_flag comes from points page
	status	char(1)	NOT NULL DEFAULT 'P',
	-- status 'A = active, I = inactive, P = prospect', status change handled by policy_customer
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	created_by int NULL,
	-- created_by takes session user_id
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.company (
-- populated by entries to carriers, lien holders, dealerships
	id	serial	PRIMARY KEY,
	type	varchar(15)	NOT NULL,
	-- type 'carrier, dealership, lienholder'
	base_url	varchar(255)	NULL,
	-- only populated for carrier, for direct link to policy
	name	varchar(255)	NOT NULL,
	phone	bigint	NULL,
	fax	bigint	NULL,
	address	varchar(255) NULL,
	city	varchar(50) NULL,
	state	char(2)	NULL,
	zip	int	NULL
);

CREATE TABLE crm.policy (
	-- populated by quote or policy page
	id	serial	PRIMARY KEY,
	policy_agent_id	int	NULL REFERENCES crm.employee(id),
	-- policy_agent_id is the employee id from user creating policy
	carrier_id	int	NULL REFERENCES crm.company(id),
	type	varchar(30)	NOT NULL,
	-- type for now is 'auto', to give room for future expansion
	quote_number varchar(50) NULL,
	quote_amt numeric NULL,
	policy_number	varchar(50) NULL,
	created_date	timestamp NOT NULL,
	-- created_date now() at record creation
	effective_date	timestamp NULL,
	first_payment_date	timestamp	NULL,
	policy_term int NULL,
	-- policy_term (1, 6, or 12 months) 
	renewal_date	timestamp NULL,
	-- renewal_date calculated by effective_date + interval '%(months)s months', {'months': policy_term}
	-- e.g. now() + interval '6 months'
	status	varchar(15)	NOT NULL DEFAULT 'Quote',
	-- status 'Quote, Autopay, Non-Pay, Renewal, Charge, Cancelled'
	/* if status updated to cancelled
	UPDATE policy SET cancelled_date = now() where id = @policy_id
	UPDATE policy_customer SET active_flag = 0 where policy_id = @policy_id
	UPDATE policy_car SET active_flag = 0 where policy_id = @policy_id
	*/
	/* if status updated to ('Autopay', 'Non-Pay', 'Renewal', 'Charge')
	UPDATE coverage SET active_flag = 1 where policy_id = @policy_id
	UPDATE policy_customer SET active_flag = 1 where policy_id = @policy_id
	UPDATE policy_car SET active_flag = 1 where policy_id = @policy_id
	*/
	premium_amt	numeric NULL,
	cancelled_date	timestamp	NULL,
	-- cancelled_date only populated if status = 'Cancelled'
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.policy_payment (
	-- populated when policy status changed from quote to autopay, nonpay, renewal
	-- one line for each payment month in terms with default status = U
	id	serial	PRIMARY KEY,
	policy_id int	NOT NULL REFERENCES crm.policy(id),
	payment_number	int	NOT NULL,	
	-- payment_number (1 for 1st payment, 2 for second payment, etc)
	/* 
	for i in range(0, policy.payment_term):
		INSERT INTO policy_payment VALUES (DEFAULT, @policy_id, i, ...)
	*/
	payment_date	timestamp	NOT NULL,
	--payment_date is date payment is due for payment number
	-- payment_date is policy.created_date + interval 'payment_number months',
	-- policy.created_date + interval '2 months' for payment number 2 for policy_id
	status	char(1)	NOT NULL	DEFAULT 'U',
	-- status 'P = Paid, U = Unpaid, C = Cancelled'
	created_date	timestamp NOT NULL,
	-- created_date now() at record creation
	updated_date	timestamp	NOT NULL,
	-- updated_date now() at record creation and ANY update to record
	updated_by	int	NOT NULL
	-- updated_by takes session user_id
);


CREATE TABLE crm.policy_customer (
	-- populated by drivers page
	id	serial	PRIMARY KEY,
	policy_id	int	NOT NULL REFERENCES crm.policy(id),
	customer_id	int	NOT NULL REFERENCES crm.customer(id),
	primary_flag	BOOLEAN	NOT NULL,
	-- primary_flag '1=primary, 0=other',
	relation	varchar(50)	NULL,
	active_flag	smallint	NULL	DEFAULT NULL,
	-- updated by policy.status update
	-- 1 = active on policy, 0 = inactive on policy, NULL is quote
	/* for any entry/update to active_flag
	if
(SELECT max(active) from policy_customer where customer_id = @customer_id) = 1
then (UPDATE customer SET status = 'A' WHERE id = @customer_id)
else
(SELECT max(active) from policy_customer where customer_id = @customer_id) = 0
then (UPDATE customer SET status = 'I' WHERE id = @customer_id)
	*/
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.car (
-- populated by vehicles page
	id	serial	PRIMARY KEY,
	lienholder_id	int	NULL REFERENCES crm.company(id),
	-- lienholder_id comes from lien holder page, populate with company(id)
	/* if
	(SELECT id from company where name = @company_name) is null then create new company record
	*/
	dealership_id	int	NULL,
	-- dealership_id comes from dealership page, populate with company(id)
	/* if
	(SELECT id from company where name = @company_name) is null then create new company record
	*/
	vin	char(17)	NOT NULL,
	make	varchar(25)	NULL,
	model	varchar(25)	NULL,
	year	int	NULL,
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);


CREATE TABLE crm.coverage (
	-- populated by vehicles page, coverage page
	id	serial	PRIMARY KEY,
	policy_id	int	NOT NULL REFERENCES crm.policy(id),
	car_id	int	NOT NULL REFERENCES crm.car(id),
	type	varchar(25)	NOT NULL,
	-- type 'Liability, Full Comprehensive, Full Collision',
	deductible_amount	numeric	NULL,
	-- deductible only populated if type <> 'Liability'
	pip_flag	BOOLEAN	NOT NULL	DEFAULT FALSE,
	-- updated by coverage page
	uninsured_motor_flag	BOOLEAN	NOT NULL	DEFAULT FALSE,
	-- updated by coverage page
	rental_flag	BOOLEAN	NOT NULL DEFAULT FALSE,
	-- updated by coverage page
	towing_flag	BOOLEAN	NOT NULL DEFAULT FALSE,
	-- updated by coverage page
	active_flag	smallint	NULL	DEFAULT NULL,
	-- updated by policy.status update
	-- 1 = active on policy, 0 = inactive on policy, null is quote
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.contact_info (
	-- populated by contact page
	id	serial	PRIMARY KEY,
	customer_id	int NOT NULL REFERENCES crm.customer(id),
	type	varchar(20)	NOT NULL,
	-- type 'Mobile Phone, Home Phone, Fax Number, Work Address'
	value	varchar(255)	NOT NULL,
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.payment_info (
	id	serial	PRIMARY KEY,
	customer_id	int NOT NULL REFERENCES crm.customer(id),
	type	char(2)	NOT NULL,	
	-- type 'CC = Credit Card, DD = Direct Deposit'
	name	varchar(255)	NOT NULL,
	-- name'if CC then name on CC, if DD then bank name'
	number	varchar(255)	NOT NULL,
	-- number 'if CC then CC number, if DD then routing-account number (combined separated by dash); all encrypted'
	last_four	char(4)	NULL,
	-- last_four 'if CC then last four digits before encryption'
	cvv	varchar(5)	NULL,
	-- cvv 'if CC then not null, else null',
	expiration_date	timestamp	NULL,	
	-- expiration_date 'if CC then not null, else null',
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	active_flag	BOOLEAN	NOT NULL DEFAULT TRUE
	-- in future will need job to monitor if expiration_date > now() then active_flag = 0, to remind the user of expired info
);

CREATE TABLE crm.note (
	-- populated by notes section on customer page
	id	serial	PRIMARY KEY,
	customer_id	int	NOT NULL REFERENCES crm.customer(id),
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	note	varchar(255) NULL,
	created_by int NOT NULL,
	-- created_by is the user id creating the note, from employee(id)
	updated_date timestamp NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

/* for new note creation
INSERT INTO audit_header VALUES (DEFAULT, 'note', note.id, 'create', employee.id, employee.first_name + ' ' + employee.last_name, now());
INSERT INTO audit_detail VALUES (DEFAULT, (select id from audit_header where entity = 'note' and record_id = @note.id), 'customer_id', null, note.customer_id, 'int');
INSERT INTO audit_detail VALUES (DEFAULT, (select id from audit_header where entity = 'note' and record_id = @note.id), 'note', null, note.note, 'varchar(255)');
*/
/* for note update
INSERT INTO audit_header VALUES (DEFAULT, 'note', note.id, 'update', employee.id, employee.first_name + ' ' + employee.last_name, now());
INSERT INTO audit_detail VALUES (DEFAULT, (select id from audit_header where entity = 'note' and action = 'update' and record_id = @note.id and changed_at = @note.updated_date), 'note', (select new_value from audit_detail join audit_header on audit_header.id = audit_detail.header_id where audit_header.record_id = @note.id and audit_header.changed_at = max(changed_at)), note.note, 'varchar(255)');
*/
/* for note deletion
INSERT INTO audit_header VALUES (DEFAULT, 'note', note.id, 'destroy', employee.id, employee.first_name + ' ' + employee.last_name, now());
*/

CREATE TABLE crm.task (
	-- populated from tasks for a customer
	id	serial	PRIMARY KEY,
	note_id	int	NOT NULL REFERENCES crm.note(id),
	category	varchar(30)	NOT NULL,
	-- category 'pop, requote, contract, other',
	created_date	timestamp	NOT NULL,
	-- created_date now() at record creation
	created_by	int	NOT NULL,
	-- created_by takes session user id from employee(id)
	due_date	timestamp	NOT NULL,
	assigned_to	int	NOT NULL,	
	-- assigned_to 'if not specified, = created_by',
	completed_flag	BOOLEAN	NOT NULL DEFAULT FALSE,	
	-- completed_flag changes to 1 when marked complete
	updated_date	timestamp	NOT NULL
	-- updated_date now() at record creation and ANY update to record
);

CREATE TABLE crm.rep (
	id	serial	PRIMARY KEY,
	company_id	int	NULL REFERENCES crm.company(id),
	/* if
	(SELECT id from company where name = @company_name) is null then create new company record
	*/
	first_name	varchar(50)	NOT NULL,
	last_name	varchar(50)	NULL,
	title	varchar(50)	NULL,
	phone	bigint	NULL,
	fax	bigint	NULL,
	email	varchar(255)	NULL,
	comments	varchar(255)	NULL
);




CREATE TABLE crm.audit_header (
	id	serial	PRIMARY KEY,
	entity	varchar(50)	NOT NULL,
	-- entity is table name
	record_id	int	NOT NULL,
	action	varchar(10)	NOT NULL,
	-- action 'create, update, destroy',
	user_id	int	NOT NULL,
	-- user_id comes from employee(id) of session user who made change
	user_name	varchar(255)	NOT NULL,
	-- user_name 'employee.first_name + ' ' + employee.last_name',
	changed_at	timestamp	NOT NULL
	-- changed_at is now() at record creation
);

CREATE TABLE crm.audit_detail (
	-- no detail if audit_header.action = destroy
	id	serial	PRIMARY KEY,
	header_id	int	NOT NULL REFERENCES crm.audit_header(id),
	field	varchar(50)	NOT NULL,
	-- field is column name
	old_value	varchar(255)	NULL,
	-- old_value is null unless audit_header.action = update
	new_value	varchar(255)	NOT NULL,
	value_type	varchar(100)	NOT NULL
	-- value_type is data type
);
