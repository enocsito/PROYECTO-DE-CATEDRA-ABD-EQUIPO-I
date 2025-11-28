CREATE DATABASE HospitalDB

USE HospitalDB

CREATE TABLE Paciente
(
	id INT PRIMARY KEY IDENTITY,
	nombres NVARCHAR(40) NOT NULL,
	apellidos NVARCHAR(40) NOT NULL,
	genero VARCHAR (40) NOT NULL,
	telefono VARCHAR(20) NOT NULL UNIQUE
)

CREATE TABLE Cita 
(
	id INT PRIMARY KEY IDENTITY,
	fecha_y_hora DATETIME NOT NULL,
	costo INT NOT NULL,
	id_paciente INT NOT NULL,
	id_medico INT NOT NULL
)

CREATE TABLE Medico 
(
	id INT PRIMARY KEY IDENTITY,
	nombres NVARCHAR(40) NOT NULL,
	apellidos NVARCHAR(40) NOT NULL,
	telefono CHAR(12) NOT NULL UNIQUE,
	id_cargo INT NOT NULL
)

CREATE TABLE Cargo
(
	id INT PRIMARY KEY,
	nombre NVARCHAR(40) NOT NULL
)

CREATE TABLE Tratamiento
(
	id INT PRIMARY KEY IDENTITY,
	descripcion NVARCHAR(100) NOT NULL,
	costo INT NOT NULL,
	id_cita INT NOT NULL
)

CREATE TABLE TratamientoXMedicamento
(
	id INT PRIMARY KEY IDENTITY,
	id_tratamiento INT NOT NULL,
	id_medicamento INT NOT NULL,
	cantidad_medicamento INT NOT NULL
)

CREATE TABLE Medicamento
(
	id INT PRIMARY KEY IDENTITY,
	nombre NVARCHAR(40) NOT NULL,
	costo INT NOT NULL,
	id_categoria_medicamento INT NOT NULL
)

CREATE TABLE CategoriaMedicamento
(
	id INT PRIMARY KEY IDENTITY,
	nombre NVARCHAR(40) NOT NULL,
)

CREATE TABLE Factura 
(
	id INT PRIMARY KEY IDENTITY,
	total DECIMAL(10,2) NOT NULL,
	id_paciente INT NOT NULL,
	id_medico INT NOT NULL
)

-- Creacion de llaves foraneas
ALTER TABLE Cita
ADD CONSTRAINT FK_Cita_Paciente
FOREIGN KEY (id_paciente) REFERENCES Paciente(id);


ALTER TABLE Tratamiento
ADD CONSTRAINT FK_Tratamiento_Cita
FOREIGN KEY (id_cita) REFERENCES Cita(id);


ALTER TABLE TratamientoXMedicamento
ADD CONSTRAINT FK_TratamientoXMedicamento_Tratamiento
FOREIGN KEY (id_tratamiento) REFERENCES Tratamiento(id);

ALTER TABLE TratamientoXMedicamento
ADD CONSTRAINT FK_TratamientoXMedicamento_Medicamento
FOREIGN KEY (id_medicamento) REFERENCES Medicamento(id);

ALTER TABLE Medicamento
ADD CONSTRAINT FK_Medicamento_CategoriaMedicamento
FOREIGN KEY (id_categoria_medicamento) REFERENCES CategoriaMedicamento(id);

ALTER TABLE Factura
ADD CONSTRAINT FK_Factura_Paciente
FOREIGN KEY (id_paciente) REFERENCES Paciente(id);

ALTER TABLE Factura
ADD CONSTRAINT FK_Factura_Medico
FOREIGN KEY (id_medico) REFERENCES Medico(id);

ALTER TABLE Medico
ADD CONSTRAINT FK_Medico_Cargo
FOREIGN KEY (id_cargo) REFERENCES Cargo(id);

-- Organización en esquemas por área de negocio
USE HospitalDB;
GO

-- 1. Creación de esquemas (si no existen)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'clinico')
    EXEC('CREATE SCHEMA clinico');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'farmacia')
    EXEC('CREATE SCHEMA farmacia');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'finanzas')
    EXEC('CREATE SCHEMA finanzas');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'config')
    EXEC('CREATE SCHEMA config');
GO

-- 2. Transferir tablas al esquema correspondiente

-- Esquema clínico: atención y registro médico
ALTER SCHEMA clinico TRANSFER dbo.Paciente;
ALTER SCHEMA clinico TRANSFER dbo.Medico;
ALTER SCHEMA clinico TRANSFER dbo.Cita;
ALTER SCHEMA clinico TRANSFER dbo.Tratamiento;
ALTER SCHEMA clinico TRANSFER dbo.TratamientoXMedicamento;
ALTER SCHEMA clinico TRANSFER dbo.Cargo;

-- Esquema farmacia: catálogo de medicamentos
ALTER SCHEMA farmacia TRANSFER dbo.Medicamento;
ALTER SCHEMA farmacia TRANSFER dbo.CategoriaMedicamento;

-- Esquema finanzas: facturación
ALTER SCHEMA finanzas TRANSFER dbo.Factura;

-- Insercion de datos

BULK INSERT clinico.Paciente
FROM 'C:\bulkData\Paciente.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT farmacia.Medicamento
FROM 'C:\bulkData\Medicamento.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT farmacia.CategoriaMedicamento
FROM 'C:\bulkData\CategoriaMedicamento.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT clinico.Medico
FROM 'C:\bulkData\Medico.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT clinico.TratamientoXMedicamento
FROM 'C:\bulkData\TratamientoXMedicamento.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT clinico.Tratamiento
FROM 'C:\bulkData\Tratamiento.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT finanzas.Factura
FROM 'C:\bulkData\Factura.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

BULK INSERT clinico.Cita
FROM 'C:\bulkData\Cita.csv'
WITH (
   FIELDTERMINATOR = ',',  
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2,           
   CODEPAGE = '1251'       
);

-- Usuarios y roles
-----1.creacion de logins
---Login Administradores 
USE master; 

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'AdminBackups')
    DROP LOGIN AdminBackups;
GO

 IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'adminGeneral')
  BEGIN
    CREATE LOGIN [adminGeneral] 
    WITH PASSWORD = 'UCA@2025_AG ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "adminGeneral"'
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'adminBackups')
  BEGIN
    CREATE LOGIN [adminBackups] 
    WITH PASSWORD = 'UCA@2025_AB ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "adminBackups"'
GO
--Rol de dbcreator para que pueda realizar los restore
ALTER SERVER ROLE [dbcreator] ADD MEMBER adminBackups

----Login Recepcion 
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'recepcion01')
  BEGIN
    CREATE LOGIN [recepcion01] 
    WITH PASSWORD = 'UCA@2025_r01 ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "recepcion01"'
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'recepcion02')
  BEGIN
    CREATE LOGIN [recepcion02] 
    WITH PASSWORD = 'UCA@2025_r02 ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "recepcion02"'
GO

------Login Medicos 

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'drCarlos')
  BEGIN
    CREATE LOGIN [drCarlos] 
    WITH PASSWORD = 'UCA@2025_drC ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "drCarlos"'
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'drGabriel')
  BEGIN
    CREATE LOGIN [drGabriel] 
    WITH PASSWORD = 'UCA@2025_drG ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "drGabriel"'
GO

-----Login Farmacia 
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'farmacia')
  BEGIN
    CREATE LOGIN [farmacia] 
    WITH PASSWORD = 'UCA@2025_F ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "farmacia"'
GO

---Login Facturacion 
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'facturacion')
  BEGIN
    CREATE LOGIN [facturacion] 
    WITH PASSWORD = 'UCA@2025_FAC ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "facturacion"'
GO

----Login Reportes
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'reportes')
  BEGIN
    CREATE LOGIN [reportes] 
    WITH PASSWORD = 'UCA@2025_R ', 
    CHECK_POLICY = ON,          
    CHECK_EXPIRATION = OFF;      
  END
  ELSE 
    PRINT 'Ya existe el Login "reportes"'
GO


------2.Creacion de Users 
---User Administradores 

  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'adminGeneral')
  BEGIN
    CREATE USER [adminGeneral] FOR LOGIN [adminGeneral];
  END
  ELSE
    PRINT 'Ya existe el usuario "adminGeneral" en HospitalDB'
  GO


  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'adminBackups')
  BEGIN
    CREATE USER [adminBackups] FOR LOGIN [adminBackups];
  END
  ELSE
    PRINT 'Ya existe el usuario "adminBackups" en HospitalDB'
  GO
  --permisos de los backup
  EXEC sp_addrolemember 'db_backupoperator', 'adminBackups'



----User Recepcion 
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'recepcion01')
  BEGIN
    CREATE USER [recepcion01] FOR LOGIN [recepcion01];
  END
  ELSE
    PRINT 'Ya existe el usuario "adminBackups" en HospitalDB'
  GO

  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'recepcion02')
  BEGIN
    CREATE USER [recepcion02] FOR LOGIN [recepcion02];
  END
  ELSE
    PRINT 'Ya existe el usuario "recepcion02" en HospitalDB'
  GO


------User Medicos 

 IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'drCarlos')
  BEGIN
    CREATE USER [drCarlos] FOR LOGIN [drCarlos];
  END
  ELSE
    PRINT 'Ya existe el usuario "drCarlos" en HospitalDB'
  GO

 IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'drGabriel')
  BEGIN
    CREATE USER [drGabriel] FOR LOGIN [drGabriel];
  END
  ELSE
    PRINT 'Ya existe el usuario "drGabriel" en HospitalDB'
  GO


----- User Farmacia 
 IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'farmacia')
  BEGIN
    CREATE USER [farmacia] FOR LOGIN [farmacia];
  END
  ELSE
    PRINT 'Ya existe el usuario "farmacia" en HospitalDB'
  GO

--- User Facturacion 
 IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'facturacion')
  BEGIN
    CREATE USER [facturacion] FOR LOGIN [facturacion];
  END
  ELSE
    PRINT 'Ya existe el usuario "facturacion" en HospitalDB'
  GO
---- User Reportes

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'reportes')
  BEGIN
    CREATE USER [reportes] FOR LOGIN [reportes];
  END
  ELSE
    PRINT 'Ya existe el usuario "reportes" en HospitalDB'
  GO

----- 3.Creacion de roles y asignacion de permisos 
-- 3.1 Asignar roles predefinidos 

ALTER ROLE db_owner
ADD MEMBER adminGeneral;
GO

ALTER ROLE db_backupoperator
ADD MEMBER adminBackups;
GO

-- Asignar rol predefinido para reportes
ALTER ROLE db_datareader
ADD MEMBER reportes;
GO

-- 3.2 Creación de roles 
---- Rol Recepcion 
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_recepcion')
  BEGIN
      CREATE ROLE rol_recepcion ;
  END
  ELSE
      PRINT 'Ya existe el rol "rol_recepcion" en HospitalDB';
----Rol Medico 
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_medico')
  BEGIN
      CREATE ROLE rol_medico ;
  END
  ELSE
      PRINT 'Ya existe el rol "rol_medico" en HospitalDB';
---- Rol Farmacia 
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_farmacia')
  BEGIN
      CREATE ROLE rol_farmacia ;
  END
  ELSE
      PRINT 'Ya existe el rol "rol_farmacia" en HospitalDB';
---- Rol Facturacion
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'rol_facturacion')
  BEGIN
      CREATE ROLE rol_facturacion ;
  END
  ELSE
      PRINT 'Ya existe el rol "rol_facturacion" en HospitalDB';

-- 3.3 Asignar permisos a cada rol 
-- 3.3 Asignar permisos a cada rol 

-- rol_recepcion
GRANT SELECT, INSERT, UPDATE ON clinico.Paciente      TO rol_recepcion;
GRANT SELECT, INSERT, UPDATE ON clinico.Cita          TO rol_recepcion;
GRANT SELECT                  ON clinico.Medico       TO rol_recepcion;
GRANT SELECT ON config.Cargo TO rol_recepcion;
GO

-- rol_medico
GRANT SELECT                  ON clinico.Paciente             TO rol_medico;
GRANT SELECT                  ON clinico.Cita                 TO rol_medico;
GRANT SELECT                  ON farmacia.Medicamento         TO rol_medico;
GRANT SELECT                  ON farmacia.CategoriaMedicamento TO rol_medico;
GRANT SELECT, INSERT, UPDATE  ON clinico.Tratamiento          TO rol_medico;
GRANT SELECT, INSERT, UPDATE  ON clinico.TratamientoXMedicamento TO rol_medico;
GRANT SELECT ON config.Cargo TO rol_medico;
GO

-- rol_farmacia
GRANT SELECT, INSERT, UPDATE  ON farmacia.Medicamento         TO rol_farmacia;
GRANT SELECT, INSERT, UPDATE  ON farmacia.CategoriaMedicamento TO rol_farmacia;
GRANT SELECT                  ON clinico.TratamientoXMedicamento TO rol_farmacia;
GO

-- rol_facturacion
GRANT SELECT, INSERT, UPDATE  ON finanzas.Factura             TO rol_facturacion;
GRANT SELECT                  ON clinico.Paciente             TO rol_facturacion;
GRANT SELECT                  ON clinico.Medico               TO rol_facturacion;
GRANT SELECT                  ON clinico.Cita                 TO rol_facturacion;
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------
--- AUDITORÍA A NIVEL SERVIDOR 

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_audits WHERE name = N'Audit_HospitalDB')
BEGIN
    CREATE SERVER AUDIT Audit_HospitalDB
    TO FILE 
    (
        FILEPATH = 'C:\audits_hospital\', 
        MAXSIZE = 50 MB
    )
    WITH 
    (
        QUEUE_DELAY = 1000,
        ON_FAILURE = CONTINUE 
    );
END;
GO

ALTER SERVER AUDIT Audit_HospitalDB
WITH (STATE = ON);
GO

-- Activar la auditoría del servidor
ALTER SERVER AUDIT Audit_HospitalDB
WITH (STATE = ON);
GO

---- AUDITORÍA A NIVEL DE BASE DE DATOS 

USE HospitalDB;
GO

CREATE DATABASE AUDIT SPECIFICATION Audit_DB_Transacciones
FOR SERVER AUDIT Audit_HospitalDB
    -- Tabla Factura
    ADD (INSERT ON OBJECT::dbo.Factura BY PUBLIC),
    ADD (UPDATE ON OBJECT::dbo.Factura BY PUBLIC),
    ADD (DELETE ON OBJECT::dbo.Factura BY PUBLIC),
    -- Tabla Cita
    ADD (INSERT ON OBJECT::dbo.Cita BY PUBLIC),
    ADD (UPDATE ON OBJECT::dbo.Cita BY PUBLIC),
    ADD (DELETE ON OBJECT::dbo.Cita BY PUBLIC)
WITH (STATE = ON);
GO

--Backups 
--Backup full

Backup DATABASE HospitalDB
	TO DISK = 'C:\Backup_DB\HospitalDB_full.bak'
	WITH INIT, 
	NAME = 'Backup FULL HospitalDB'

--Backup DIFF
Backup DATABASE HospitalDB
	TO DISK = 'C:\Backup_DB\HospitalDB_diff.bak'
	WITH DIFFERENTIAL, NAME = 'Differencial backup HospitalDB';

--Backup LOG
BACKUP LOG HospitalDB
	TO DISK = 'C:\Backup_DB\HospitalDB_log0015.trn'
	WITH Compression, NAME = 'Backup log0015 de HospitalDB'


--Restauracion FULL de HosptitalDB
USE master

RESTORE DATABASE HospitalDB
	FROM DISK = 'C:\Backup_DB\HospitalDB_full.bak'
	WITH  NORECOVERY;

RESTORE DATABASE HospitalDB
	FROM DISK = 'C:\Backup_DB\HospitalDB_diff.bak'
	WITH  NORECOVERY;

RESTORE LOG HospitalDB
	FROM DISK = 'C:\Backup_DB\HospitalDB_log0015.trn'
	WITH  RECOVERY;

RESTORE DATABASE HospitalDB WITH RECOVERY;


---------------------------------------JOBS---------------------------------------------------------------------------------------------------
----Job backup FULL
USE [msdb]
GO

/****** Object:  Job [Backup full]    Script Date: 27/11/2025 18:18:34 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 27/11/2025 18:18:34 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup full', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Este job se realizara cada semana', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'adminBackups', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup full]    Script Date: 27/11/2025 18:18:34 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup full', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Backup DATABASE HospitalDB
TO DISK = ''C:\Backup_DB\HospitalDB_full.bak''
WITH INIT, 
NAME = ''Backup FULL HospitalDB''', 
		@database_name=N'HospitalDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Backup semanal', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20251126, 
		@active_end_date=99991231, 
		@active_start_time=60000, 
		@active_end_time=235959, 
		@schedule_uid=N'127265f1-8265-40b3-9209-e2796fe192ae'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

--JOB backup DIFF
USE [msdb]
GO

/****** Object:  Job [Backupp diff]    Script Date: 27/11/2025 18:22:36 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 27/11/2025 18:22:37 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backupp diff', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Este job realizara el backup de forma diaria', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'adminBackups', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup diario]    Script Date: 27/11/2025 18:22:37 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup diario', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Backup DATABASE HospitalDB
TO Disk = ''C:\Backup_DB\HospitalDB_diff.bak''
WITH DIFFERENTIAL, NAME = ''Differencial backup HospitalDB'';
', 
		@database_name=N'HospitalDB', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Diario', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20251126, 
		@active_end_date=99991231, 
		@active_start_time=235900, 
		@active_end_time=235959, 
		@schedule_uid=N'0e81c043-7f8a-4ee8-b4de-6bd2c581c494'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


-- Funciones Ventana

--Muestra el promedio de las ultimas 3 citas que recibio
-- 
SELECT C.id_paciente, C.fecha_y_hora, C.costo,
  AVG(C.costo) OVER (
    PARTITION BY C.id_paciente
    ORDER BY C.fecha_y_hora
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS PromedioUltimas3
FROM clinico.Cita AS C;

--RANK() Ranking de Médicos por Ventas (Con empates saltando puestos)
-- Clasifica a los médicos según el total facturado.

SELECT 
    M.nombres + ' ' + M.apellidos AS Medico,
    SUM(F.total) AS TotalFacturado,
    RANK() OVER (ORDER BY SUM(F.total) DESC) AS RankingVentas
FROM finanzas.Factura F
JOIN clinico.Medico M ON F.id_medico = M.id
GROUP BY M.id, M.nombres, M.apellidos;
GO

--SUM() OVER(): Total Acumulado de Facturación
--Muestra el ingreso acumulado factura por factura (Running Total) para ver el crecimiento de ingresos a lo largo del tiempo (simulado por ID).
SELECT 
    id AS IdFactura,
    id_paciente,
    total AS MontoActual,
    SUM(total) OVER (ORDER BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM finanzas.Factura;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

--INDICES

CREATE INDEX IX_Cita_Paciente_Fecha
ON clinico.Cita(id_paciente, fecha_y_hora ASC)
INCLUDE (costo);

CREATE INDEX IX_Factura_Medico_Total
ON finanzas.Factura(id_medico)
INCLUDE (total);

CREATE INDEX IX_Medico_Id_Nombres
ON clinico.Medico(id)
INCLUDE (nombres, apellidos);

CREATE INDEX IX_Factura_Id_Total
ON finanzas.Factura(id ASC)
INCLUDE (id_paciente, total);

