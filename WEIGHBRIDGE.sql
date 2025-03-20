-- create database --
create database weightbridge;
-- use database --
use weightbridge;
-- create tables--
CREATE TABLE Vehicle (
    Vehicle_ID INT PRIMARY KEY AUTO_INCREMENT,
    Vehicle_Number VARCHAR(20) UNIQUE NOT NULL,
    Vehicle_Type VARCHAR(50) NOT NULL,
    Driver_Name VARCHAR(100),
    Driver_Contact VARCHAR(15) -- Allows international numbers
);
CREATE TABLE Load_status (
    Load_ID INT PRIMARY KEY AUTO_INCREMENT,
    Vehicle_ID INT,
    Gross_Weight DECIMAL(10,2) NOT NULL, -- Weight in kg/tons
    Tare_Weight DECIMAL(10,2) NOT NULL, -- Empty vehicle weight
    Net_Weight DECIMAL(10,2) GENERATED ALWAYS AS (Gross_Weight - Tare_Weight) STORED,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID) ON DELETE CASCADE
);

CREATE TABLE Materials (
    Material_ID INT PRIMARY KEY AUTO_INCREMENT,
    Material_Name VARCHAR(100) NOT NULL,
    Material_Type VARCHAR(50) NOT NULL, -- Solid, Liquid, etc.
    Density DECIMAL(10,3), -- Density of material
    Unit_of_Measurement VARCHAR(10) NOT NULL -- Kg, Tons, etc.
);

CREATE TABLE Weighbridge_Record (
    Record_ID INT PRIMARY KEY AUTO_INCREMENT,
    Vehicle_ID INT,
    Load_ID INT,
    Material_ID INT,
    Date_Time DATETIME DEFAULT CURRENT_TIMESTAMP,
    Weighbridge_Location VARCHAR(255),
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID) ON DELETE CASCADE,
    FOREIGN KEY (Load_ID) REFERENCES Load_status(Load_ID) ON DELETE CASCADE,
    FOREIGN KEY (Material_ID) REFERENCES Materials(Material_ID) ON DELETE CASCADE
);
-- insert values into tables--
insert into vehicle(VEHICLE_NUMBER,VEHICLE_TYPE,DRIVER_NAME,DRIVER_CONTACT) VALUES
('TN20BM1810','LORRY','KUMARAN',6379042970),
('TN73Y3337','TRAILER','BHARATH',7868949171),
('TN04AK2399','TEMPO','SANJAY',9843923663);
INSERT INTO LOAD_STATUS (Vehicle_ID, Gross_Weight, Tare_Weight, Timestamp) VALUES
(1, 15000.50, 5000.00, '2025-03-06 10:30:00'),
(2, 25000.75, 7000.25, '2025-03-06 11:00:00'),
(3, 18000.00, 6000.00, '2025-03-06 11:30:00');
INSERT INTO Materials (Material_Name, Material_Type, Density, Unit_of_Measurement) VALUES
('Cement', 'Solid', 1.44, 'Tons'),
('Coal', 'Solid', 1.30, 'Tons'),
('Diesel', 'Liquid', 0.85, 'Liters'),
('Sand', 'Solid', 1.60, 'Tons'),
('Gravel', 'Solid', 1.50, 'Tons');
INSERT INTO Weighbridge_Record (Vehicle_ID, Load_ID, Material_ID, Date_Time, Weighbridge_Location) VALUES
(1, 1, 1, '2025-03-06 10:35:00', 'Chennai'),
(2, 2, 2, '2025-03-06 11:05:00', 'Coimbatore'),
(3, 3, 3, '2025-03-06 11:40:00', 'Madurai'),
(1, 1, 4, '2025-03-06 12:15:00', 'Trichy'),
(2, 2, 5, '2025-03-06 12:45:00', 'Salem');
-- select tables--
SELECT*FROM VEHICLE;
SELECT*FROM LOAD_STATUS;
SELECT*FROM MATERIALS;
SELECT*FROM WEIGHBRIDGE_RECORD;
-- view creation--
-- View for Vehicles Carrying Load > 10,000 kg--
CREATE VIEW Vehicles_Heavy_Load AS
SELECT v.Vehicle_ID, v.Vehicle_Number, l.Gross_Weight 
FROM Vehicle v
JOIN Load_status l ON v.Vehicle_ID = l.Vehicle_ID
WHERE l.Gross_Weight > 10000;
-- call view --
select * from vehicles_heavy_load;
-- View for Net Weight Calculation--
CREATE VIEW Load_Net_Weight AS
SELECT Load_ID, Gross_Weight, Tare_Weight, 
       (Gross_Weight - Tare_Weight) AS Net_Weight
FROM Load_status;
-- call view --
select * from load_net_weight;
-- View for Load Count at Each Weighbridge--
CREATE VIEW Load_Count_By_Weighbridge AS
SELECT Weighbridge_Location, COUNT(*) AS Total_Loads
FROM Weighbridge_Record
GROUP BY Weighbridge_Location;
-- call view --
select * from load_count_by_weighbridge;
-- Procedure to Retrieve All Vehicle Details--
DELIMITER //
CREATE PROCEDURE GetAllVehicles()
BEGIN
    SELECT * FROM Vehicle;
END //
DELIMITER ;
-- Call Procedure--
CALL GetAllVehicles();
-- Procedure to Count Total Loads--
DELIMITER //
CREATE PROCEDURE GetTotalLoads()
BEGIN
    SELECT COUNT(*) AS Total_Loads FROM Load_status;
END //
DELIMITER ;
-- Call Procedure--
CALL GetTotalLoads();
-- Procedure to Show All Materials --

DELIMITER //
CREATE PROCEDURE GetAllMaterials()
BEGIN
    SELECT Material_Name, Material_Type, Density FROM Materials;
END //
DELIMITER ;
-- Call Procedure --
CALL GetAllMaterials();
-- Procedure to Retrieve Latest 5 Weighbridge Records--
DELIMITER //
CREATE PROCEDURE GetLatestWeighbridgeRecords()
BEGIN
    SELECT * FROM Weighbridge_Record
    ORDER BY Date_Time DESC
    LIMIT 5;
END //
DELIMITER ;

-- Call Procedure--
CALL GetLatestWeighbridgeRecords();
-- Procedure to Find Vehicles that Transported Cement --
 DELIMITER //
CREATE PROCEDURE GetVehiclesTransportingCement()
BEGIN
    SELECT DISTINCT v.Vehicle_Number, m.Material_Name
    FROM Vehicle v
    JOIN Load_status l ON v.Vehicle_ID = l.Vehicle_ID
    JOIN Weighbridge_Record w ON l.Load_ID = w.Load_ID
    JOIN Materials m ON w.Material_ID = m.Material_ID
    WHERE m.Material_Name = 'Cement';
END //
DELIMITER ;
-- Call Procedure --
CALL GetVehiclesTransportingCement();
-- Procedure to Find the Vehicle Carrying the Heaviest Load --
DELIMITER //
CREATE PROCEDURE GetHeaviestLoadVehicle()
BEGIN
    SELECT v.Vehicle_ID, v.Vehicle_Number, l.Gross_Weight
    FROM Vehicle v
    JOIN Load_status l ON v.Vehicle_ID = l.Vehicle_ID
    ORDER BY l.Gross_Weight DESC
    LIMIT 1;
    
END //
DELIMITER ;
-- Call Procedure --
CALL GetHeaviestLoadVehicle();
--  update a contact value in vehicle table--
DELIMITER //

CREATE PROCEDURE UpdateVehicleContact1(
    IN p_Vehicle_ID INT,
    IN p_New_Contact VARCHAR(15)
)
BEGIN
    UPDATE Vehicle
    SET Driver_Contact = p_New_Contact
    WHERE Vehicle_ID = p_Vehicle_ID;
    select*from vehicle;
END //

DELIMITER ;
-- call procedure --
CALL UpdateVehicleContact1(1, '9876543210');
-- View WeighbridgeView --

CREATE VIEW WeighbridgeView AS
SELECT 
    wr.Record_ID,
    v.Vehicle_Number,
    v.Vehicle_Type,
    l.Gross_Weight,
    l.Tare_Weight,
    l.Net_Weight,
    m.Material_Name,
    m.Material_Type,
    wr.Date_Time,
    wr.Weighbridge_Location
FROM Weighbridge_Record wr
JOIN Vehicle v ON wr.Vehicle_ID = v.Vehicle_ID
JOIN Load_status l ON wr.Load_ID = l.Load_ID
JOIN Materials m ON wr.Material_ID = m.Material_ID;
-- call view --
select * from weighbridgeview;
Procedure to Find Vehicles Transporting a Specific Material

DELIMITER //
CREATE PROCEDURE GetVehiclesTransportingMaterial(IN material_name_param VARCHAR(50))
BEGIN
    SELECT DISTINCT v.Vehicle_Number, m.Material_Name
    FROM Vehicle v
    JOIN Load_status l ON v.Vehicle_ID = l.Vehicle_ID
    JOIN Weighbridge_Record w ON l.Load_ID = w.Load_ID
    JOIN Materials m ON w.Material_ID = m.Material_ID
    WHERE m.Material_Name = material_name_param;
END //
DELIMITER ;
-- call procedure--
call getvehiclestransportingmaterial('cement');