select * from ffd.user_dim;
select * from ffd.group_dim;
select * from ffd.company_dim;

select * from ffd.account_dim;
select * from ffd.costtype_dim;

delete from ffd.user_dim;
delete from ffd.group_dim;
delete from ffd.company_dim;
delete from ffd.account_dim;


INSERT INTO ffd.user_dim (id, name) VALUES (-1, 'UNDEFINED');
INSERT INTO ffd.group_dim (id, name) VALUES (-1, 'UNDEFINED');
INSERT INTO ffd.company_dim (id, name) VALUES (-1, 'UNDEFINED');


INSERT INTO ffd.account_dim (id, name, comment, level_type) VALUES (-1, 'UNDEFINED', 'default account for level 1', 1);
INSERT INTO ffd.account_dim (id, name, comment, level_type) VALUES (-2, 'UNDEFINED', 'default account for level 2', 2);
INSERT INTO ffd.account_dim (id, name, comment, level_type) VALUES (-3, 'UNDEFINED', 'default account for level 3', 3);

INSERT INTO ffd.costtype_dim (id, name, comment) VALUES (-1, 'UNDEFINED', 'default costtype');
