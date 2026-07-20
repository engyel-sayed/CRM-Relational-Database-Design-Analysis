CREATE DATABASE CRM_System_Final_V4;
GO

USE CRM_System_Final_V4;
GO

CREATE TABLE Departments (
    dept_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    location NVARCHAR(100)
);

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role NVARCHAR(50),
    status NVARCHAR(20) DEFAULT 'Active',
    dept_id INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

CREATE TABLE Clients (
    client_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    email VARCHAR(100),
    address NVARCHAR(255),
    status NVARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE Client_Phones (
    phone_id INT PRIMARY KEY IDENTITY(1,1),
    phone_number VARCHAR(20) NOT NULL,
    client_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);

CREATE TABLE Marketing_Campaigns (
    campaign_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    budget DECIMAL(18, 2),
    start_date DATE,
    end_date DATE
);

CREATE TABLE Client_Attract (
    client_id INT NOT NULL,
    campaign_id INT NOT NULL,
    PRIMARY KEY (client_id, campaign_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (campaign_id) REFERENCES Marketing_Campaigns(campaign_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description NVARCHAR(255)
);

CREATE TABLE Deals (
    deal_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100),
    status NVARCHAR(50), 
    start_date DATE DEFAULT GETDATE(),
    end_date DATE
);

CREATE TABLE Deals_Products (
    deal_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (deal_id, product_id),
    FOREIGN KEY (deal_id) REFERENCES Deals(deal_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Support_Tickets (
    ticket_id INT PRIMARY KEY IDENTITY(1,1),
    issue_description NVARCHAR(MAX) NOT NULL,
    priority NVARCHAR(20),
    status NVARCHAR(20) DEFAULT 'Open',
    created_at DATETIME DEFAULT GETDATE(),
    client_id INT NOT NULL,
    employee_id INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

CREATE TABLE Activity_Types (
    activity_id INT PRIMARY KEY IDENTITY(1,1),
    type_name NVARCHAR(50) NOT NULL
);

CREATE TABLE Deal_Interactions (
    employee_id INT NOT NULL,
    client_id INT NOT NULL,
    deal_id INT NOT NULL,      
    activity_id INT NOT NULL,
    PRIMARY KEY (employee_id, client_id, deal_id, activity_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    FOREIGN KEY (deal_id) REFERENCES Deals(deal_id),
    FOREIGN KEY (activity_id) REFERENCES Activity_Types(activity_id)
);
GO

INSERT INTO Departments (name, location) VALUES 
('Sales Dept', 'Floor 1'), 
('Marketing Dept', 'Floor 2'), 
('Customer Support', 'Floor 3'), 
('IT & Tech', 'Server Room'), 
('HR', 'Admin Building');

INSERT INTO Employees (name, email, role, status, dept_id) VALUES 
('Ahmed Ali', 'ahmed@crm.com', 'Sales Manager', 'Active', 1),
('Mona Zaki', 'mona@crm.com', 'Marketing Specialist', 'Active', 2),
('Kareem Adel', 'kareem@crm.com', 'Support Agent', 'Active', 3),
('Sara Samy', 'sara@crm.com', 'Sales Rep', 'Active', 1),
('Omar Hisham', 'omar@crm.com', 'IT Admin', 'Active', 4);

INSERT INTO Clients (name, email, address, status) VALUES 
('Tech Corp', 'info@tech.com', 'Cairo', 'Active'),
('Global Trade', 'contact@global.com', 'Alex', 'Active'),
('Dr. Sherif', 'sherif@clinic.com', 'Giza', 'Active'),
('Smart School', 'admin@school.com', 'Nasr City', 'Inactive'),
('Alpha Build', 'eng@alpha.com', 'Capital', 'Active');

INSERT INTO Client_Phones (phone_number, client_id) VALUES 
('01010101010', 1), 
('01122334455', 1), 
('01200000000', 2), 
('01555555555', 3), 
('0224446666', 4);

INSERT INTO Marketing_Campaigns (name, budget, start_date, end_date) VALUES 
('Summer Offer', 50000, '2026-06-01', '2026-08-31'),
('Black Friday', 20000, '2026-11-20', '2026-11-30'),
('Facebook Ads', 10000, '2026-01-01', '2026-12-31'),
('Email Blast', 2000, '2026-02-01', '2026-02-28'),
('Google SEO', 15000, '2026-01-01', '2026-06-30');

INSERT INTO Client_Attract (client_id, campaign_id) VALUES 
(1, 3), 
(2, 5), 
(3, 1), 
(4, 2), 
(5, 3);

INSERT INTO Products (name, price, description) VALUES 
('CRM License', 5000, 'Enterprise'), 
('ERP System', 20000, 'Full Setup'), 
('Mobile App', 15000, 'iOS/Android'), 
('Web Hosting', 1000, 'Yearly'), 
('Consulting', 500, 'Hourly');

INSERT INTO Deals (name, status, start_date) VALUES 
('CRM Upgrade', 'Negotiation', '2026-02-01'),
('ERP Deal', 'Won', '2026-01-15'),
('Clinic App', 'Lost', '2026-01-10'),
('School Site', 'Won', '2026-01-20'),
('Construction Soft', 'Proposal', '2026-02-06');

INSERT INTO Deals_Products (deal_id, product_id) VALUES 
(1, 1), 
(1, 5), 
(2, 2), 
(3, 3), 
(4, 4);

INSERT INTO Activity_Types (type_name) VALUES 
('Phone Call'), 
('Meeting'),    
('Email'),      
('Site Visit'), 
('Demo');       

INSERT INTO Deal_Interactions (employee_id, client_id, deal_id, activity_id) VALUES 
(1, 1, 1, 1),       
(1, 2, 2, 2),        
(4, 3, 3, 3),   
(3, 4, 4, 1),      
(4, 5, 5, 5);
INSERT INTO Support_Tickets (issue_description, priority, status, client_id, employee_id) VALUES 
('Login Error', 'High', 'Open', 1, 3),
('Invoice Mistake', 'Medium', 'Resolved', 2, 3),
('Password Reset', 'Low', 'Closed', 3, 5),
('Server Down', 'High', 'In Progress', 4, 5),
('Feature Request', 'Low', 'Open', 5, 3);