USE [master]
GO
/****** Object:  Database [u_pastuszk]    Script Date: 24.01.2021 23:43:02 ******/
CREATE DATABASE [u_pastuszk]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'u_pastuszk', FILENAME = N'/var/opt/mssql/data/u_pastuszk.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'u_pastuszk_log', FILENAME = N'/var/opt/mssql/data/u_pastuszk_log.ldf' , SIZE = 66048KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [u_pastuszk] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [u_pastuszk].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [u_pastuszk] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [u_pastuszk] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [u_pastuszk] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [u_pastuszk] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [u_pastuszk] SET ARITHABORT OFF 
GO
ALTER DATABASE [u_pastuszk] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [u_pastuszk] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [u_pastuszk] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [u_pastuszk] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [u_pastuszk] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [u_pastuszk] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [u_pastuszk] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [u_pastuszk] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [u_pastuszk] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [u_pastuszk] SET  ENABLE_BROKER 
GO
ALTER DATABASE [u_pastuszk] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [u_pastuszk] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [u_pastuszk] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [u_pastuszk] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [u_pastuszk] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [u_pastuszk] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [u_pastuszk] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [u_pastuszk] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [u_pastuszk] SET  MULTI_USER 
GO
ALTER DATABASE [u_pastuszk] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [u_pastuszk] SET DB_CHAINING OFF 
GO
ALTER DATABASE [u_pastuszk] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [u_pastuszk] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [u_pastuszk] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [u_pastuszk] SET QUERY_STORE = OFF
GO
USE [u_pastuszk]
GO
/****** Object:  UserDefinedTableType [dbo].[ListaDan]    Script Date: 24.01.2021 23:43:02 ******/
CREATE TYPE [dbo].[ListaDan] AS TABLE(
	[DanieID] [int] NOT NULL,
	[IloscZamowionych] [int] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ListaPracownikowFirm]    Script Date: 24.01.2021 23:43:02 ******/
CREATE TYPE [dbo].[ListaPracownikowFirm] AS TABLE(
	[PracownikID] [int] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[ListaStolikow]    Script Date: 24.01.2021 23:43:02 ******/
CREATE TYPE [dbo].[ListaStolikow] AS TABLE(
	[StolikID] [int] NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[StolikiPrzezListeMiejsc]    Script Date: 24.01.2021 23:43:02 ******/
CREATE TYPE [dbo].[StolikiPrzezListeMiejsc] AS TABLE(
	[IloscMiejsc] [int] NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[StolikZObostrzeniem]    Script Date: 24.01.2021 23:43:02 ******/
CREATE TYPE [dbo].[StolikZObostrzeniem] AS TABLE(
	[StolikID] [int] NOT NULL,
	[IloscMiejsc] [int] NOT NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[czyJestFirma]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[czyJestFirma](@klientid INT)
RETURNS BIT
AS
    BEGIN
        IF @klientid IN (SELECT FirmaID
                         FROM Firma
                         )
            BEGIN
                RETURN 1
            END
	return 0
    END
GO
/****** Object:  UserDefinedFunction [dbo].[czyJestPracownikiemFirmy]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[czyJestPracownikiemFirmy](@klientid INT, @companyid INT)
RETURNS BIT
AS
    BEGIN
        DECLARE @res INT = (SELECT COUNT(PracownikID)
                              FROM PracownicyFirm
                              WHERE PracownikID = @klientid AND FirmaID = @companyid)
        IF @res > 0
            BEGIN
                RETURN 1
            END
        return 0
    END
GO
/****** Object:  UserDefinedFunction [dbo].[czyKlientMozeRezerwowacPrzezInternet]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[czyKlientMozeRezerwowacPrzezInternet](@klientid INT, @ordervalue decimal(18, 10))
RETURNS BIT
AS
    BEGIN
        IF @ordervalue < 50
            BEGIN
                RETURN 0
            END
        ELSE IF @ordervalue >= 200
            BEGIN
                RETURN 1
            END

        DECLARE @numberOfOrders AS INT = (SELECT COUNT(ZamPrzezKlient)
                                          FROM Zamowienia
                                          WHERE ZamPrzezKlient = @klientid)

        IF @numberOfOrders >= 5
            BEGIN
                RETURN 1
            END
        return 0
    END
GO
/****** Object:  UserDefinedFunction [dbo].[rabat_kwartalny_dla_daty]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[rabat_kwartalny_dla_daty] (@date date, @companyid int)
returns decimal(18, 10)
as begin
   DECLARE @suminquarter int
   DECLARE @sumspenttocurrentorder int
   DECLARE @firstdayinquarter DATE
   DECLARE @sumtospend MONEY
   DECLARE @discountid INT

    SET @discountid = (SELECT RabatID FROM dbo.RabatKwartalnyHitoria 
					    WHERE DATEDIFF(QUARTER, @date, RKHistData) = 0 AND
							  FirmaID = @companyid)
   
	IF @discountid IS NOT NULL 
	    BEGIN 

		 SET @suminquarter = (SELECT SUM(ZRabatemMiesiecznym) FROM dbo.WartoscZamowieniaFirmy 
							  WHERE DATEPART(QUARTER, DataZlorzeniaZamowienia) = 
									DATEPART(QUARTER, DATEADD(QUARTER, -1, @date)) 
									AND 
									YEAR(DataZlorzeniaZamowienia) = 
									YEAR(@date) 
									AND
									ZamowionePrzez = @companyid)

		 SET @sumtospend = @suminquarter * (SELECT RKInfoProcOdKwoty 
											FROM dbo.RabatKwartalnyInfo
											WHERE RKInfoID = @discountid)
	--     
		 -- get first date of current quarter
		 SET @firstdayinquarter = DATEADD(qq, DATEDIFF(qq, 0, @date), 0)
		 
	--     suma bez rabatu kwartalnego
		 SET @sumspenttocurrentorder = (SELECT SUM(ZRabatemMiesiecznym)
										FROM dbo.WartoscZamowieniaFirmy
										WHERE 
										  @date > DataZlorzeniaZamowienia
										  AND 
										  @firstdayinquarter < DataZlorzeniaZamowienia)
		 
		 IF @sumspenttocurrentorder IS NULL SET @sumspenttocurrentorder = 0
		 
		SET @sumtospend -= @sumspenttocurrentorder

-- 		 RETURN 1
		 RETURN CASE WHEN @sumtospend > 0 THEN @sumtospend ELSE 0 END 
	   END 
	RETURN 0
-- 	RETURN 0
END
GO
/****** Object:  UserDefinedFunction [dbo].[rabat_miesieczny_dla_daty]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[rabat_miesieczny_dla_daty](@date date, @client int)
RETURNS DECIMAL(18, 10)
AS BEGIN
	DECLARE @startdate date
	DECLARE @discountid int

		SELECT @startdate = RMHistDataOd, @discountid = RabatID
		FROM dbo.RabatMiesiecznyHistoria
		WHERE 
				FirmaID = @client AND
				RMHistDataOd <= @date AND
			   (RMHistDataDo IS NULL OR RMHistDataDo >= @date) 

	DECLARE @discount DECIMAL(18, 10)
	DECLARE @maxdiscount DECIMAL(18, 10)

		SELECT @discount = RMInfoPrzyrostRabatu, @maxdiscount = RMInfoMaksRabat
		FROM dbo.RabatMiesiecznyInfo
		WHERE RMInfoRabatID = @discountid

	IF @discount IS NULL
		SET @discount = 0
	IF @maxdiscount IS NULL
		SET @maxdiscount = 0
	IF @startdate IS NULL
		SET @startdate = @date

	IF @maxdiscount < @discount
	  BEGIN
		SET @discount = @maxdiscount
	  END 
	
	RETURN 1 - @discount * DATEDIFF(MONTH, @startdate, @date)
END
GO
/****** Object:  UserDefinedFunction [dbo].[rabat_staly_indywidualnego_dla_daty]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[rabat_staly_indywidualnego_dla_daty] (@date date, @clientid int)
returns decimal(18, 10)
as begin
    declare @discount decimal(18, 10)
    declare @rank int
    declare @discountid int

    select @rank = MAX(RHRanga)
    from RangaHistoria
    where KindID = @clientid and RHDataPrzyznaniaRangi <= @date and (RHDataUmorzenia is NULL or RHDataUmorzenia >= @date)
    
    select @discountid = RabatID
    from RangaHistoria
    where KindID = @clientid and RHDataPrzyznaniaRangi <= @date and (RHDataUmorzenia is NULL or RHDataUmorzenia >= @date)
                   and RHRanga = @rank

    set @discount = (select RSInfoRabat
                    from RabatStalyInfo
                    where RSInfoRabatID = @discountid)

    IF @discount IS NULL SET @discount = 1

    return cast(power((1-@discount), @rank) as decimal(18, 10))
end
GO
/****** Object:  UserDefinedFunction [dbo].[rabat_tymczasowy_indywidualnego_dla_daty]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[rabat_tymczasowy_indywidualnego_dla_daty] (@date date, @clientid int)
returns decimal(18, 10)
as begin
	declare @discount decimal(18, 10)
	
	declare @ids table(id int)

	set @discount = (select cast(EXP(SUM(LOG(1-RTInfoRabat))) as decimal(18,10))
                            from PrzyznanyRabatTymczasowy
                            inner join RabatTymczasowyInfo RTI on PrzyznanyRabatTymczasowy.RabatID = RTI.RTInfoRabatID
                            where KIndID = @clientid and @date between PRTDataOd and dateadd(week, 1, PRTDataOd))

	IF @discount IS NULL SET @discount = 1

	return @discount
end
GO
/****** Object:  UserDefinedFunction [dbo].[wolne_stoliki]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[wolne_stoliki] (@date SMALLDATETIME)
RETURNS @WolneStoliki TABLE (StolikID INT, IloscMiejsc INT)
AS BEGIN
	INSERT INTO @WolneStoliki
		SELECT s.StolikID, sdm.SDMIloscDostepnychMiejsc
		FROM Stoliki s 
			INNER JOIN StolikiDostepneMiejsca sdm ON s.StolikID = sdm.StolikID
			INNER JOIN StolikiRezerwacje sr ON  sdm.SDMID = sr.SDMID
			LEFT OUTER JOIN Rezerwacje r ON sr.RezID = r.RezID
		WHERE
			sdm.SDMDataOd <= @date AND (sdm.SDMDataDo IS NULL OR sdm.SDMDataDo >= @date)
			AND
			sdm.SDMIloscDostepnychMiejsc > 0
			AND
			NOT EXISTS (SELECT subr.RezID FROM Rezerwacje subr 
						WHERE 
							subr.RezID = r.RezID AND
							@date BETWEEN subr.RezDataIGodzina AND DATEADD(HOUR, 1, subr.RezDataIGodzina))

	RETURN
END
GO
/****** Object:  Table [dbo].[TypDania]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypDania](
	[TypID] [int] NOT NULL,
	[TypNazwa] [varchar](50) NOT NULL,
 CONSTRAINT [PK_TypDania] PRIMARY KEY CLUSTERED 
(
	[TypID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Dania]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dania](
	[DanieID] [int] NOT NULL,
	[DanieNazwa] [varchar](50) NOT NULL,
	[TypID] [int] NOT NULL,
 CONSTRAINT [PK_Dania] PRIMARY KEY CLUSTERED 
(
	[DanieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[OwoceMorza]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OwoceMorza] as
	SELECT DanieID 
	FROM dbo.Dania d
	INNER JOIN dbo.TypDania td ON td.TypID = d.TypID
	WHERE td.TypNazwa = 'Owoce morza'
GO
/****** Object:  Table [dbo].[StolikiDostepneMiejsca]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StolikiDostepneMiejsca](
	[SDMID] [int] NOT NULL,
	[StolikID] [int] NOT NULL,
	[SDMDataOd] [date] NOT NULL,
	[SDMDataDo] [date] NULL,
	[SDMIloscDostepnychMiejsc] [int] NOT NULL,
 CONSTRAINT [PK_StolikiDostepneMiejsca] PRIMARY KEY CLUSTERED 
(
	[SDMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stoliki]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stoliki](
	[StolikID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
	[StolikMaksIloscMiejsc] [int] NOT NULL,
 CONSTRAINT [PK_Stoliki] PRIMARY KEY CLUSTERED 
(
	[StolikID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DostepneStoliki]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[DostepneStoliki] as
select SDM.StolikID, SDM.SDMIloscDostepnychMiejsc, S.RestauracjaID
from StolikiDostepneMiejsca SDM
inner join Stoliki S on S.StolikID = SDM.StolikID
where SDMDataOd < GETDATE() and (SDMDataDo is NULL or SDMDataDo >= GETDATE()) and SDMIloscDostepnychMiejsc > 0
GO
/****** Object:  Table [dbo].[SzczegolyZamowienia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SzczegolyZamowienia](
	[ZamID] [int] NOT NULL,
	[DanieID] [int] NOT NULL,
	[SZIlosc] [int] NOT NULL,
 CONSTRAINT [PK_SzczegółyZamówienia] PRIMARY KEY CLUSTERED 
(
	[ZamID] ASC,
	[DanieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Zamowienia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Zamowienia](
	[ZamID] [int] NOT NULL,
	[ZamPrzezKlient] [int] NOT NULL,
	[ZamDataZlozenia] [date] NOT NULL,
	[ZamPreferowanaDataOdbioru] [date] NULL,
	[ZamDataPlatnosci] [date] NULL,
	[ZamDataOdbioru] [date] NULL,
	[ZamTyp] [int] NOT NULL,
	[ZamSposobPlatnosci] [int] NULL,
	[ZamNrKonta] [varchar](50) NULL,
	[ZamZatwierdzonePrzezPrac] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
 CONSTRAINT [PK_Zamówienia] PRIMARY KEY CLUSTERED 
(
	[ZamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DaniaOkresyWMenu]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DaniaOkresyWMenu](
	[DOMID] [int] NOT NULL,
	[DanieID] [int] NOT NULL,
	[DOMCena] [money] NOT NULL,
	[DOMDataWstawienia] [date] NOT NULL,
	[DOMDataZdjecia] [date] NULL,
	[RestauracjaID] [int] NOT NULL,
 CONSTRAINT [PK_DaniaOkresyWMenu_1] PRIMARY KEY CLUSTERED 
(
	[DOMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KlientIndywidualny]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KlientIndywidualny](
	[KIndID] [int] NOT NULL,
	[KIndImie] [varchar](50) NOT NULL,
	[KIndNazwisko] [varchar](50) NOT NULL,
 CONSTRAINT [PK_KlientIndywidualny] PRIMARY KEY CLUSTERED 
(
	[KIndID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[WartoscZamowieniaKlientaIdywidualnego]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[WartoscZamowieniaKlientaIdywidualnego]
as
select		Z.ZamID AS IDZamowienia, Z.ZamPrzezKlient AS ZamowionePrzez,
			SUM(SZ.SZIlosc * DOWM.DOMCena) AS BezRabatu, 
			dbo.rabat_staly_indywidualnego_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) AS RabatStaly,
			dbo.rabat_tymczasowy_indywidualnego_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) AS RabatTymczasowy,
			SUM(SZ.SZIlosc * DOWM.DOMCena * dbo.rabat_staly_indywidualnego_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) *
            dbo.rabat_tymczasowy_indywidualnego_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient)) AS ZRabatem
from Zamowienia Z
			INNER join SzczegolyZamowienia SZ on SZ.ZamID = Z.ZamID
			INNER join Dania D on D.DanieID = SZ.DanieID
            inner join DaniaOkresyWMenu DOWM on D.DanieID = DOWM.DanieID
WHERE DOWM.DOMDataWstawienia <= Z.ZamDataZlozenia AND
      (DOWM.DOMDataZdjecia IS NULL OR DOWM.DOMDataZdjecia >= ZamDataZlozenia) AND
	  Z.ZamPrzezKlient IN (SELECT KindID FROM dbo.KlientIndywidualny)
GROUP BY Z.ZamID, Z.ZamPrzezKlient, Z.ZamDataZlozenia
GO
/****** Object:  Table [dbo].[RabatStalyInfo]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabatStalyInfo](
	[RSInfoRabatID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
	[RSInfoMinWartoscZamowienia] [money] NOT NULL,
	[RSInfoIloscZamowienDoAwansuRangi] [int] NOT NULL,
	[RSInfoRabat] [decimal](18, 10) NOT NULL,
	[RSInfoAktualneOd] [date] NOT NULL,
	[RSInfoAktualneDo] [date] NULL,
 CONSTRAINT [PK_RabatStalyInfo] PRIMARY KEY CLUSTERED 
(
	[RSInfoRabatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AktualnyRabatStaly]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[AktualnyRabatStaly] as
select RSInfoRabatID, RSInfoMinWartoscZamowienia, RSInfoIloscZamowienDoAwansuRangi, RSInfoRabat
from RabatStalyInfo
where RSInfoAktualneOd <= GETDATE() and (RSInfoAktualneDo is NULL or RSInfoAktualneDo >= GETDATE())
GO
/****** Object:  Table [dbo].[Firma]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Firma](
	[FirmaID] [int] NOT NULL,
	[FirmaNazwa] [varchar](50) NOT NULL,
	[FirmaAdres] [varchar](50) NOT NULL,
	[FirmaMiastoID] [int] NOT NULL,
	[FirmaKodPocztowy] [varchar](50) NOT NULL,
	[FirmaFax] [varchar](50) NULL,
	[FirmaNrNIP] [varchar](50) NOT NULL,
	[FirmaFakturaMiesieczna] [bit] NOT NULL,
 CONSTRAINT [PK_Firma] PRIMARY KEY CLUSTERED 
(
	[FirmaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[WartoscZamowieniaFirmy]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WartoscZamowieniaFirmy]
as
select		Z.ZamID AS IDZamowienia, Z.ZamDataZlozenia AS DataZlorzeniaZamowienia, Z.ZamPrzezKlient AS ZamowionePrzez,
			SUM(SZ.SZIlosc * DOWM.DOMCena) AS BezRabatu, 
			dbo.rabat_miesieczny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) AS RabatMiesieczny,
			dbo.rabat_kwartalny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) AS RabatKwartalny,
			SUM(SZ.SZIlosc * DOWM.DOMCena * dbo.rabat_miesieczny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient))
			  AS ZRabatemMiesiecznym,
			SUM(
					 CASE WHEN 
							  SZ.SZIlosc * DOWM.DOMCena * 
							  dbo.rabat_miesieczny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) -
							  dbo.rabat_kwartalny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) >= 0 
					 THEN SZ.SZIlosc * DOWM.DOMCena * 
						  dbo.rabat_miesieczny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient) -
						  dbo.rabat_kwartalny_dla_daty(Z.ZamDataZlozenia, Z.ZamPrzezKlient)
					 ELSE 0
					 END 
				) AS ZRabatemKwartalnym
from Zamowienia Z
	 inner join SzczegolyZamowienia SZ on SZ.ZamID = Z.ZamID
	 inner join Dania D on D.DanieID = SZ.DanieID
     inner join DaniaOkresyWMenu DOWM on D.DanieID = DOWM.DanieID
WHERE DOWM.DOMDataWstawienia <= Z.ZamDataZlozenia AND
      (DOWM.DOMDataZdjecia IS NULL OR DOWM.DOMDataZdjecia >= ZamDataZlozenia) AND
	  Z.ZamPrzezKlient IN (SELECT FirmaID FROM dbo.Firma)
GROUP BY Z.ZamID, Z.ZamPrzezKlient, Z.ZamDataZlozenia
GO
/****** Object:  Table [dbo].[RabatTymczasowyInfo]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabatTymczasowyInfo](
	[RTInfoRabatID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
	[RTInfoKwotaProgowa] [money] NOT NULL,
	[RTInfoRabat] [decimal](18, 10) NOT NULL,
	[RTInfoOkres] [int] NOT NULL,
	[RTInfoAktualneOd] [date] NOT NULL,
	[RTInfoAktualneDo] [date] NULL,
 CONSTRAINT [PK_RabatTymczasowyInfo] PRIMARY KEY CLUSTERED 
(
	[RTInfoRabatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AktualnyRabatTymczasowy]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[AktualnyRabatTymczasowy] as
select RTInfoRabatID, RTInfoKwotaProgowa, RTInfoRabat, RTInfoOkres, RestauracjaID
from RabatTymczasowyInfo
where RTInfoAktualneOd <= GETDATE() and (RTInfoAktualneDo is NULL or RTInfoAktualneDo >= GETDATE())
GO
/****** Object:  Table [dbo].[DaniaPolprodukty]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DaniaPolprodukty](
	[DanieID] [int] NOT NULL,
	[PProdID] [int] NOT NULL,
 CONSTRAINT [PK_DaniaPolprodukty] PRIMARY KEY CLUSTERED 
(
	[DanieID] ASC,
	[PProdID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DoDodania]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DoDodania](
	[DanieID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
	[DDCena] [money] NOT NULL,
 CONSTRAINT [PK_DoDodania_1] PRIMARY KEY CLUSTERED 
(
	[DanieID] ASC,
	[RestauracjaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DoUsuniecia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DoUsuniecia](
	[DanieID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
 CONSTRAINT [PK_DoUsuniecia_1] PRIMARY KEY CLUSTERED 
(
	[DanieID] ASC,
	[RestauracjaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Klient]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Klient](
	[KlientID] [int] NOT NULL,
	[KlientNrTel] [varchar](50) NOT NULL,
	[KlientEmail] [varchar](50) NOT NULL,
	[KlientDataDolaczenia] [date] NOT NULL,
 CONSTRAINT [PK_Klient] PRIMARY KEY CLUSTERED 
(
	[KlientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KlientRestauracji]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KlientRestauracji](
	[KlientID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
 CONSTRAINT [PK_KlientRestauracji] PRIMARY KEY CLUSTERED 
(
	[KlientID] ASC,
	[RestauracjaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Kraje]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Kraje](
	[KrajID] [int] NOT NULL,
	[KrajNazwa] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Panstwa] PRIMARY KEY CLUSTERED 
(
	[KrajID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ListyPracownikowDoRezerwacji]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListyPracownikowDoRezerwacji](
	[RezID] [int] NOT NULL,
	[PracownikID] [int] NOT NULL,
 CONSTRAINT [PK_ListaPracownikowDoRezerwacji] PRIMARY KEY CLUSTERED 
(
	[RezID] ASC,
	[PracownikID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menu]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menu](
	[DanieID] [int] NOT NULL,
	[DanieCena] [money] NOT NULL,
	[MenuDataOd] [date] NOT NULL,
	[MenuDataDo] [date] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
 CONSTRAINT [PK_Menu_1] PRIMARY KEY CLUSTERED 
(
	[DanieID] ASC,
	[RestauracjaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Miasta]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Miasta](
	[MiastoID] [int] NOT NULL,
	[MiastoNazwa] [varchar](50) NOT NULL,
	[KrajID] [int] NOT NULL,
 CONSTRAINT [PK_Miasta] PRIMARY KEY CLUSTERED 
(
	[MiastoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Polprodukty]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Polprodukty](
	[PProdID] [int] NOT NULL,
	[Nazwa] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Polprodukty] PRIMARY KEY CLUSTERED 
(
	[PProdID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PolproduktyWRestauracji]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolproduktyWRestauracji](
	[RestairacjaID] [int] NOT NULL,
	[PProdID] [int] NOT NULL,
	[PWRIloscDostepnych] [int] NOT NULL,
 CONSTRAINT [PK_PolproduktyWRestauracji] PRIMARY KEY CLUSTERED 
(
	[RestairacjaID] ASC,
	[PProdID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Pracownicy]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pracownicy](
	[PracownikID] [int] NOT NULL,
	[PracownikImie] [varchar](50) NOT NULL,
	[PracownikNazwisko] [varchar](50) NOT NULL,
	[PracownikPESEL] [varchar](50) NOT NULL,
	[RestauracjaID] [int] NOT NULL,
 CONSTRAINT [PK_Pracownicy] PRIMARY KEY CLUSTERED 
(
	[PracownikID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PracownicyFirm]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PracownicyFirm](
	[PracownikID] [int] NOT NULL,
	[PracownikImie] [varchar](50) NOT NULL,
	[PracownikNazwisko] [varchar](50) NOT NULL,
	[FirmaID] [int] NOT NULL,
 CONSTRAINT [PK_PracownicyFirm] PRIMARY KEY CLUSTERED 
(
	[PracownikID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PrzyznanyRabatTymczasowy]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrzyznanyRabatTymczasowy](
	[PRTID] [nchar](10) NOT NULL,
	[RabatID] [int] NOT NULL,
	[KIndID] [int] NOT NULL,
	[PRTDataOd] [date] NOT NULL,
 CONSTRAINT [PK_PrzyznanyRabatTymczasowy] PRIMARY KEY CLUSTERED 
(
	[PRTID] ASC,
	[RabatID] ASC,
	[KIndID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RabatKwartalnyHitoria]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabatKwartalnyHitoria](
	[RKHID] [int] NOT NULL,
	[FirmaID] [int] NOT NULL,
	[RabatID] [int] NOT NULL,
	[RKHistData] [date] NOT NULL,
 CONSTRAINT [PK_RabatKwartalnyHitoria] PRIMARY KEY CLUSTERED 
(
	[RKHID] ASC,
	[FirmaID] ASC,
	[RabatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RabatKwartalnyInfo]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabatKwartalnyInfo](
	[RKInfoID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
	[RKInfoMinSumaWKwartale] [money] NOT NULL,
	[RKInfoProcOdKwoty] [decimal](18, 10) NOT NULL,
	[RKInfoAktualneOd] [date] NOT NULL,
	[RKInfoAktualneDo] [date] NULL,
 CONSTRAINT [PK_RabatKwartalnyInfo] PRIMARY KEY CLUSTERED 
(
	[RKInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RabatMiesiecznyHistoria]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabatMiesiecznyHistoria](
	[RMHID] [nchar](10) NOT NULL,
	[FirmaID] [int] NOT NULL,
	[RabatID] [int] NOT NULL,
	[RMHistDataOd] [date] NOT NULL,
	[RMHistDataDo] [date] NULL,
 CONSTRAINT [PK_RabatMiesiecznyHistoria_1] PRIMARY KEY CLUSTERED 
(
	[RMHID] ASC,
	[FirmaID] ASC,
	[RabatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RabatMiesiecznyInfo]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RabatMiesiecznyInfo](
	[RMInfoRabatID] [int] NOT NULL,
	[RestauracjaID] [int] NOT NULL,
	[RMInfoIloscZamWMies] [int] NOT NULL,
	[RMInfoMinSumaZamWMies] [money] NOT NULL,
	[RMInfoPrzyrostRabatu] [decimal](18, 10) NOT NULL,
	[RMInfoMaksRabat] [decimal](18, 10) NOT NULL,
	[RMInfoAktualneOd] [date] NOT NULL,
	[RMInfoAktualneDo] [date] NULL,
 CONSTRAINT [PK_RabatMiesiecznyInfo] PRIMARY KEY CLUSTERED 
(
	[RMInfoRabatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RangaHistoria]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RangaHistoria](
	[KIndID] [int] NOT NULL,
	[RabatID] [int] NOT NULL,
	[RHRanga] [int] NOT NULL,
	[RHDataPrzyznaniaRangi] [date] NOT NULL,
	[RHDataUmorzenia] [date] NULL,
 CONSTRAINT [PK_RangaHistoria] PRIMARY KEY CLUSTERED 
(
	[KIndID] ASC,
	[RabatID] ASC,
	[RHRanga] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RestauracjaKlient]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RestauracjaKlient](
	[RestauracjaID] [int] NOT NULL,
	[KlientID] [int] NOT NULL,
 CONSTRAINT [PK_RestauracjaKlient] PRIMARY KEY CLUSTERED 
(
	[RestauracjaID] ASC,
	[KlientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Restauracje]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Restauracje](
	[RestauracjaID] [int] NOT NULL,
	[RestauracjaNazwa] [varchar](50) NOT NULL,
	[RestauracjaAdres] [varchar](50) NOT NULL,
	[RestauracjaMiasto] [int] NOT NULL,
	[RestauracjaKodPocztowy] [varchar](50) NOT NULL,
	[RestauracjaNrNIP] [varchar](50) NOT NULL,
	[RestauracjaEmail] [varchar](50) NOT NULL,
	[RestauracjaNrTel] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Restauracje] PRIMARY KEY CLUSTERED 
(
	[RestauracjaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rezerwacje]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rezerwacje](
	[RezID] [int] NOT NULL,
	[RezDataIGodzina] [smalldatetime] NULL,
 CONSTRAINT [PK_Rezerwacje_1] PRIMARY KEY CLUSTERED 
(
	[RezID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RezerwacjeDoZamowienia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RezerwacjeDoZamowienia](
	[RezID] [int] NOT NULL,
	[ZamID] [int] NOT NULL,
 CONSTRAINT [PK_Rezerwacje] PRIMARY KEY CLUSTERED 
(
	[RezID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RezerwacjeFirmBezZamowienia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RezerwacjeFirmBezZamowienia](
	[RezID] [int] NOT NULL,
	[FirmaID] [int] NOT NULL,
 CONSTRAINT [PK_RezerwacjeFirmBezZamowienia] PRIMARY KEY CLUSTERED 
(
	[RezID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SposobPlatnosci]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SposobPlatnosci](
	[SposobID] [int] NOT NULL,
	[SposobNazwa] [varchar](50) NOT NULL,
 CONSTRAINT [PK_SposobPlatnosci] PRIMARY KEY CLUSTERED 
(
	[SposobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StolikiRezerwacje]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StolikiRezerwacje](
	[SDMID] [int] NOT NULL,
	[RezID] [int] NOT NULL,
 CONSTRAINT [PK_StolikiRezerwacje] PRIMARY KEY CLUSTERED 
(
	[SDMID] ASC,
	[RezID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TypZamowienia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypZamowienia](
	[TypZamID] [int] NOT NULL,
	[TypZamNazwa] [varchar](50) NOT NULL,
 CONSTRAINT [PK_TypZamowienia] PRIMARY KEY CLUSTERED 
(
	[TypZamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [unikalna_data_rezerwacji]    Script Date: 24.01.2021 23:43:02 ******/
CREATE UNIQUE NONCLUSTERED INDEX [unikalna_data_rezerwacji] ON [dbo].[Rezerwacje]
(
	[RezDataIGodzina] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Unikatowe_Zampwienie]    Script Date: 24.01.2021 23:43:02 ******/
CREATE UNIQUE NONCLUSTERED INDEX [Unikatowe_Zampwienie] ON [dbo].[RezerwacjeDoZamowienia]
(
	[ZamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Dania]  WITH CHECK ADD  CONSTRAINT [FK_Dania_TypDania1] FOREIGN KEY([TypID])
REFERENCES [dbo].[TypDania] ([TypID])
GO
ALTER TABLE [dbo].[Dania] CHECK CONSTRAINT [FK_Dania_TypDania1]
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu]  WITH CHECK ADD  CONSTRAINT [FK_DaniaOkresyWMenu_Dania] FOREIGN KEY([DanieID])
REFERENCES [dbo].[Dania] ([DanieID])
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu] CHECK CONSTRAINT [FK_DaniaOkresyWMenu_Dania]
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu]  WITH CHECK ADD  CONSTRAINT [FK_DaniaOkresyWMenu_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu] CHECK CONSTRAINT [FK_DaniaOkresyWMenu_Restauracje]
GO
ALTER TABLE [dbo].[DaniaPolprodukty]  WITH CHECK ADD  CONSTRAINT [FK_DaniaPolprodukty_Dania] FOREIGN KEY([DanieID])
REFERENCES [dbo].[Dania] ([DanieID])
GO
ALTER TABLE [dbo].[DaniaPolprodukty] CHECK CONSTRAINT [FK_DaniaPolprodukty_Dania]
GO
ALTER TABLE [dbo].[DaniaPolprodukty]  WITH CHECK ADD  CONSTRAINT [FK_DaniaPolprodukty_Polprodukty1] FOREIGN KEY([PProdID])
REFERENCES [dbo].[Polprodukty] ([PProdID])
GO
ALTER TABLE [dbo].[DaniaPolprodukty] CHECK CONSTRAINT [FK_DaniaPolprodukty_Polprodukty1]
GO
ALTER TABLE [dbo].[DoDodania]  WITH CHECK ADD  CONSTRAINT [FK_DoDodania_Dania] FOREIGN KEY([DanieID])
REFERENCES [dbo].[Dania] ([DanieID])
GO
ALTER TABLE [dbo].[DoDodania] CHECK CONSTRAINT [FK_DoDodania_Dania]
GO
ALTER TABLE [dbo].[DoDodania]  WITH CHECK ADD  CONSTRAINT [FK_DoDodania_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[DoDodania] CHECK CONSTRAINT [FK_DoDodania_Restauracje]
GO
ALTER TABLE [dbo].[DoUsuniecia]  WITH CHECK ADD  CONSTRAINT [FK_DoUsuniecia_Menu] FOREIGN KEY([DanieID], [RestauracjaID])
REFERENCES [dbo].[Menu] ([DanieID], [RestauracjaID])
GO
ALTER TABLE [dbo].[DoUsuniecia] CHECK CONSTRAINT [FK_DoUsuniecia_Menu]
GO
ALTER TABLE [dbo].[Firma]  WITH CHECK ADD  CONSTRAINT [FK_Firma_Klient] FOREIGN KEY([FirmaID])
REFERENCES [dbo].[Klient] ([KlientID])
GO
ALTER TABLE [dbo].[Firma] CHECK CONSTRAINT [FK_Firma_Klient]
GO
ALTER TABLE [dbo].[Firma]  WITH CHECK ADD  CONSTRAINT [FK_Firma_Miasta1] FOREIGN KEY([FirmaMiastoID])
REFERENCES [dbo].[Miasta] ([MiastoID])
GO
ALTER TABLE [dbo].[Firma] CHECK CONSTRAINT [FK_Firma_Miasta1]
GO
ALTER TABLE [dbo].[KlientIndywidualny]  WITH CHECK ADD  CONSTRAINT [FK_KlientIndywidualny_Klient] FOREIGN KEY([KIndID])
REFERENCES [dbo].[Klient] ([KlientID])
GO
ALTER TABLE [dbo].[KlientIndywidualny] CHECK CONSTRAINT [FK_KlientIndywidualny_Klient]
GO
ALTER TABLE [dbo].[KlientRestauracji]  WITH CHECK ADD  CONSTRAINT [FK_KlientRestauracji_Klient] FOREIGN KEY([KlientID])
REFERENCES [dbo].[Klient] ([KlientID])
GO
ALTER TABLE [dbo].[KlientRestauracji] CHECK CONSTRAINT [FK_KlientRestauracji_Klient]
GO
ALTER TABLE [dbo].[KlientRestauracji]  WITH CHECK ADD  CONSTRAINT [FK_KlientRestauracji_Restauracje1] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[KlientRestauracji] CHECK CONSTRAINT [FK_KlientRestauracji_Restauracje1]
GO
ALTER TABLE [dbo].[ListyPracownikowDoRezerwacji]  WITH CHECK ADD  CONSTRAINT [FK_ListyPracownikowDoRezerwacji_PracownicyFirm] FOREIGN KEY([PracownikID])
REFERENCES [dbo].[PracownicyFirm] ([PracownikID])
GO
ALTER TABLE [dbo].[ListyPracownikowDoRezerwacji] CHECK CONSTRAINT [FK_ListyPracownikowDoRezerwacji_PracownicyFirm]
GO
ALTER TABLE [dbo].[ListyPracownikowDoRezerwacji]  WITH CHECK ADD  CONSTRAINT [FK_ListyPracownikowDoRezerwacji_RezerwacjeFirmBezZamowienia] FOREIGN KEY([RezID])
REFERENCES [dbo].[RezerwacjeFirmBezZamowienia] ([RezID])
GO
ALTER TABLE [dbo].[ListyPracownikowDoRezerwacji] CHECK CONSTRAINT [FK_ListyPracownikowDoRezerwacji_RezerwacjeFirmBezZamowienia]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Dania] FOREIGN KEY([DanieID])
REFERENCES [dbo].[Dania] ([DanieID])
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [FK_Menu_Dania]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [FK_Menu_Restauracje]
GO
ALTER TABLE [dbo].[Miasta]  WITH CHECK ADD  CONSTRAINT [FK_Miasta_Kraje] FOREIGN KEY([KrajID])
REFERENCES [dbo].[Kraje] ([KrajID])
GO
ALTER TABLE [dbo].[Miasta] CHECK CONSTRAINT [FK_Miasta_Kraje]
GO
ALTER TABLE [dbo].[PolproduktyWRestauracji]  WITH CHECK ADD  CONSTRAINT [FK_PolproduktyWRestauracji_Polprodukty] FOREIGN KEY([PProdID])
REFERENCES [dbo].[Polprodukty] ([PProdID])
GO
ALTER TABLE [dbo].[PolproduktyWRestauracji] CHECK CONSTRAINT [FK_PolproduktyWRestauracji_Polprodukty]
GO
ALTER TABLE [dbo].[PolproduktyWRestauracji]  WITH CHECK ADD  CONSTRAINT [FK_PolproduktyWRestauracji_Restauracje] FOREIGN KEY([RestairacjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[PolproduktyWRestauracji] CHECK CONSTRAINT [FK_PolproduktyWRestauracji_Restauracje]
GO
ALTER TABLE [dbo].[Pracownicy]  WITH CHECK ADD  CONSTRAINT [FK_Pracownicy_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[Pracownicy] CHECK CONSTRAINT [FK_Pracownicy_Restauracje]
GO
ALTER TABLE [dbo].[PracownicyFirm]  WITH CHECK ADD  CONSTRAINT [FK_PracownicyFirm_Firma1] FOREIGN KEY([FirmaID])
REFERENCES [dbo].[Firma] ([FirmaID])
GO
ALTER TABLE [dbo].[PracownicyFirm] CHECK CONSTRAINT [FK_PracownicyFirm_Firma1]
GO
ALTER TABLE [dbo].[PrzyznanyRabatTymczasowy]  WITH CHECK ADD  CONSTRAINT [FK_PrzyznanyRabatTymczasowy_KlientIndywidualny] FOREIGN KEY([KIndID])
REFERENCES [dbo].[KlientIndywidualny] ([KIndID])
GO
ALTER TABLE [dbo].[PrzyznanyRabatTymczasowy] CHECK CONSTRAINT [FK_PrzyznanyRabatTymczasowy_KlientIndywidualny]
GO
ALTER TABLE [dbo].[PrzyznanyRabatTymczasowy]  WITH CHECK ADD  CONSTRAINT [FK_PrzyznanyRabatTymczasowy_RabatTymczasowyInfo1] FOREIGN KEY([RabatID])
REFERENCES [dbo].[RabatTymczasowyInfo] ([RTInfoRabatID])
GO
ALTER TABLE [dbo].[PrzyznanyRabatTymczasowy] CHECK CONSTRAINT [FK_PrzyznanyRabatTymczasowy_RabatTymczasowyInfo1]
GO
ALTER TABLE [dbo].[RabatKwartalnyHitoria]  WITH CHECK ADD  CONSTRAINT [FK_RabatKwartalnyHitoria_Firma1] FOREIGN KEY([FirmaID])
REFERENCES [dbo].[Firma] ([FirmaID])
GO
ALTER TABLE [dbo].[RabatKwartalnyHitoria] CHECK CONSTRAINT [FK_RabatKwartalnyHitoria_Firma1]
GO
ALTER TABLE [dbo].[RabatKwartalnyHitoria]  WITH CHECK ADD  CONSTRAINT [FK_RabatKwartalnyHitoria_RabatKwartalnyInfo1] FOREIGN KEY([RabatID])
REFERENCES [dbo].[RabatKwartalnyInfo] ([RKInfoID])
GO
ALTER TABLE [dbo].[RabatKwartalnyHitoria] CHECK CONSTRAINT [FK_RabatKwartalnyHitoria_RabatKwartalnyInfo1]
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo]  WITH CHECK ADD  CONSTRAINT [FK_RabatKwartalnyInfo_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo] CHECK CONSTRAINT [FK_RabatKwartalnyInfo_Restauracje]
GO
ALTER TABLE [dbo].[RabatMiesiecznyHistoria]  WITH CHECK ADD  CONSTRAINT [FK_RabatMiesiecznyHistoria_Firma1] FOREIGN KEY([FirmaID])
REFERENCES [dbo].[Firma] ([FirmaID])
GO
ALTER TABLE [dbo].[RabatMiesiecznyHistoria] CHECK CONSTRAINT [FK_RabatMiesiecznyHistoria_Firma1]
GO
ALTER TABLE [dbo].[RabatMiesiecznyHistoria]  WITH CHECK ADD  CONSTRAINT [FK_RabatMiesiecznyHistoria_RabatMiesiecznyInfo1] FOREIGN KEY([RabatID])
REFERENCES [dbo].[RabatMiesiecznyInfo] ([RMInfoRabatID])
GO
ALTER TABLE [dbo].[RabatMiesiecznyHistoria] CHECK CONSTRAINT [FK_RabatMiesiecznyHistoria_RabatMiesiecznyInfo1]
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo]  WITH CHECK ADD  CONSTRAINT [FK_RabatMiesiecznyInfo_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo] CHECK CONSTRAINT [FK_RabatMiesiecznyInfo_Restauracje]
GO
ALTER TABLE [dbo].[RabatStalyInfo]  WITH CHECK ADD  CONSTRAINT [FK_RabatStalyInfo_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[RabatStalyInfo] CHECK CONSTRAINT [FK_RabatStalyInfo_Restauracje]
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo]  WITH CHECK ADD  CONSTRAINT [FK_RabatTymczasowyInfo_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo] CHECK CONSTRAINT [FK_RabatTymczasowyInfo_Restauracje]
GO
ALTER TABLE [dbo].[RangaHistoria]  WITH CHECK ADD  CONSTRAINT [FK_RangaHistoria_KlientIndywidualny1] FOREIGN KEY([KIndID])
REFERENCES [dbo].[KlientIndywidualny] ([KIndID])
GO
ALTER TABLE [dbo].[RangaHistoria] CHECK CONSTRAINT [FK_RangaHistoria_KlientIndywidualny1]
GO
ALTER TABLE [dbo].[RangaHistoria]  WITH CHECK ADD  CONSTRAINT [FK_RangaHistoria_RabatStalyInfo1] FOREIGN KEY([RabatID])
REFERENCES [dbo].[RabatStalyInfo] ([RSInfoRabatID])
GO
ALTER TABLE [dbo].[RangaHistoria] CHECK CONSTRAINT [FK_RangaHistoria_RabatStalyInfo1]
GO
ALTER TABLE [dbo].[RestauracjaKlient]  WITH CHECK ADD  CONSTRAINT [FK_RestauracjaKlient_Klient] FOREIGN KEY([KlientID])
REFERENCES [dbo].[Klient] ([KlientID])
GO
ALTER TABLE [dbo].[RestauracjaKlient] CHECK CONSTRAINT [FK_RestauracjaKlient_Klient]
GO
ALTER TABLE [dbo].[RestauracjaKlient]  WITH CHECK ADD  CONSTRAINT [FK_RestauracjaKlient_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[RestauracjaKlient] CHECK CONSTRAINT [FK_RestauracjaKlient_Restauracje]
GO
ALTER TABLE [dbo].[Restauracje]  WITH CHECK ADD  CONSTRAINT [FK_Restauracje_Miasta] FOREIGN KEY([RestauracjaMiasto])
REFERENCES [dbo].[Miasta] ([MiastoID])
GO
ALTER TABLE [dbo].[Restauracje] CHECK CONSTRAINT [FK_Restauracje_Miasta]
GO
ALTER TABLE [dbo].[RezerwacjeDoZamowienia]  WITH CHECK ADD  CONSTRAINT [FK_RezerwacjeDoZamowienia_Rezerwacje] FOREIGN KEY([RezID])
REFERENCES [dbo].[Rezerwacje] ([RezID])
GO
ALTER TABLE [dbo].[RezerwacjeDoZamowienia] CHECK CONSTRAINT [FK_RezerwacjeDoZamowienia_Rezerwacje]
GO
ALTER TABLE [dbo].[RezerwacjeDoZamowienia]  WITH CHECK ADD  CONSTRAINT [FK_RezerwacjeDoZamowienia_Zamowienia1] FOREIGN KEY([ZamID])
REFERENCES [dbo].[Zamowienia] ([ZamID])
GO
ALTER TABLE [dbo].[RezerwacjeDoZamowienia] CHECK CONSTRAINT [FK_RezerwacjeDoZamowienia_Zamowienia1]
GO
ALTER TABLE [dbo].[RezerwacjeFirmBezZamowienia]  WITH CHECK ADD  CONSTRAINT [FK_RezerwacjeFirmBezZamowienia_Firma] FOREIGN KEY([FirmaID])
REFERENCES [dbo].[Firma] ([FirmaID])
GO
ALTER TABLE [dbo].[RezerwacjeFirmBezZamowienia] CHECK CONSTRAINT [FK_RezerwacjeFirmBezZamowienia_Firma]
GO
ALTER TABLE [dbo].[RezerwacjeFirmBezZamowienia]  WITH CHECK ADD  CONSTRAINT [FK_RezerwacjeFirmBezZamowienia_Rezerwacje] FOREIGN KEY([RezID])
REFERENCES [dbo].[Rezerwacje] ([RezID])
GO
ALTER TABLE [dbo].[RezerwacjeFirmBezZamowienia] CHECK CONSTRAINT [FK_RezerwacjeFirmBezZamowienia_Rezerwacje]
GO
ALTER TABLE [dbo].[Stoliki]  WITH CHECK ADD  CONSTRAINT [FK_Stoliki_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[Stoliki] CHECK CONSTRAINT [FK_Stoliki_Restauracje]
GO
ALTER TABLE [dbo].[StolikiDostepneMiejsca]  WITH CHECK ADD  CONSTRAINT [FK_StolikiDostepneMiejsca_Stoliki] FOREIGN KEY([StolikID])
REFERENCES [dbo].[Stoliki] ([StolikID])
GO
ALTER TABLE [dbo].[StolikiDostepneMiejsca] CHECK CONSTRAINT [FK_StolikiDostepneMiejsca_Stoliki]
GO
ALTER TABLE [dbo].[StolikiRezerwacje]  WITH CHECK ADD  CONSTRAINT [FK_StolikiRezerwacje_Rezerwacje] FOREIGN KEY([RezID])
REFERENCES [dbo].[Rezerwacje] ([RezID])
GO
ALTER TABLE [dbo].[StolikiRezerwacje] CHECK CONSTRAINT [FK_StolikiRezerwacje_Rezerwacje]
GO
ALTER TABLE [dbo].[StolikiRezerwacje]  WITH CHECK ADD  CONSTRAINT [FK_StolikiRezerwacje_StolikiDostepneMiejsca1] FOREIGN KEY([SDMID])
REFERENCES [dbo].[StolikiDostepneMiejsca] ([SDMID])
GO
ALTER TABLE [dbo].[StolikiRezerwacje] CHECK CONSTRAINT [FK_StolikiRezerwacje_StolikiDostepneMiejsca1]
GO
ALTER TABLE [dbo].[SzczegolyZamowienia]  WITH CHECK ADD  CONSTRAINT [FK_SzczegolyZamowienia_Dania] FOREIGN KEY([DanieID])
REFERENCES [dbo].[Dania] ([DanieID])
GO
ALTER TABLE [dbo].[SzczegolyZamowienia] CHECK CONSTRAINT [FK_SzczegolyZamowienia_Dania]
GO
ALTER TABLE [dbo].[SzczegolyZamowienia]  WITH CHECK ADD  CONSTRAINT [FK_SzczegolyZamowienia_Zamowienia] FOREIGN KEY([ZamID])
REFERENCES [dbo].[Zamowienia] ([ZamID])
GO
ALTER TABLE [dbo].[SzczegolyZamowienia] CHECK CONSTRAINT [FK_SzczegolyZamowienia_Zamowienia]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [FK_Zamowienia_Klient] FOREIGN KEY([ZamPrzezKlient])
REFERENCES [dbo].[Klient] ([KlientID])
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [FK_Zamowienia_Klient]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [FK_Zamowienia_Pracownicy] FOREIGN KEY([ZamZatwierdzonePrzezPrac])
REFERENCES [dbo].[Pracownicy] ([PracownikID])
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [FK_Zamowienia_Pracownicy]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [FK_Zamowienia_Restauracje] FOREIGN KEY([RestauracjaID])
REFERENCES [dbo].[Restauracje] ([RestauracjaID])
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [FK_Zamowienia_Restauracje]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [FK_Zamowienia_SposobPlatnosci] FOREIGN KEY([ZamSposobPlatnosci])
REFERENCES [dbo].[SposobPlatnosci] ([SposobID])
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [FK_Zamowienia_SposobPlatnosci]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [FK_Zamowienia_TypZamowienia] FOREIGN KEY([ZamTyp])
REFERENCES [dbo].[TypZamowienia] ([TypZamID])
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [FK_Zamowienia_TypZamowienia]
GO
ALTER TABLE [dbo].[Dania]  WITH CHECK ADD  CONSTRAINT [wzor_nazwy_dania] CHECK  (([DanieNazwa] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[Dania] CHECK CONSTRAINT [wzor_nazwy_dania]
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu]  WITH CHECK ADD  CONSTRAINT [dania_kolejnosc_dat] CHECK  (([DOMDataZdjecia]>=[DOMDataWstawienia]))
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu] CHECK CONSTRAINT [dania_kolejnosc_dat]
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu]  WITH CHECK ADD  CONSTRAINT [dodatnia_cena_okresy_w_menu] CHECK  (([DOMCena]>(0)))
GO
ALTER TABLE [dbo].[DaniaOkresyWMenu] CHECK CONSTRAINT [dodatnia_cena_okresy_w_menu]
GO
ALTER TABLE [dbo].[DoDodania]  WITH CHECK ADD  CONSTRAINT [dodatnia_cena_do_dodania] CHECK  (([DDCena]>(0)))
GO
ALTER TABLE [dbo].[DoDodania] CHECK CONSTRAINT [dodatnia_cena_do_dodania]
GO
ALTER TABLE [dbo].[Firma]  WITH CHECK ADD  CONSTRAINT [wzor_faks_firmy] CHECK  (([FirmaFax] like '([0-9][0-9]) [0-9][0-9][0-9] [0-9][0-9] [0-9][0-9]'))
GO
ALTER TABLE [dbo].[Firma] CHECK CONSTRAINT [wzor_faks_firmy]
GO
ALTER TABLE [dbo].[Firma]  WITH CHECK ADD  CONSTRAINT [wzor_kod_pocztowy_firmy] CHECK  (([FirmaKodPocztowy] like '[0-9][0-9]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Firma] CHECK CONSTRAINT [wzor_kod_pocztowy_firmy]
GO
ALTER TABLE [dbo].[Firma]  WITH CHECK ADD  CONSTRAINT [wzor_NIP_firmy] CHECK  (([FirmaNrNIP] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Firma] CHECK CONSTRAINT [wzor_NIP_firmy]
GO
ALTER TABLE [dbo].[Klient]  WITH CHECK ADD  CONSTRAINT [phone_number_check] CHECK  (([KlientNrTel] like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Klient] CHECK CONSTRAINT [phone_number_check]
GO
ALTER TABLE [dbo].[Klient]  WITH CHECK ADD  CONSTRAINT [wzor_adresu_email] CHECK  (([KlientEmail] like '%@%.%'))
GO
ALTER TABLE [dbo].[Klient] CHECK CONSTRAINT [wzor_adresu_email]
GO
ALTER TABLE [dbo].[KlientIndywidualny]  WITH CHECK ADD  CONSTRAINT [wzor_imienia_klienta_indywidualnego] CHECK  (([KIndImie] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[KlientIndywidualny] CHECK CONSTRAINT [wzor_imienia_klienta_indywidualnego]
GO
ALTER TABLE [dbo].[KlientIndywidualny]  WITH CHECK ADD  CONSTRAINT [wzor_nazwiska_klienta_indywidualnego] CHECK  (([KIndNazwisko] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[KlientIndywidualny] CHECK CONSTRAINT [wzor_nazwiska_klienta_indywidualnego]
GO
ALTER TABLE [dbo].[Kraje]  WITH CHECK ADD  CONSTRAINT [wzor_nazwy_kraju] CHECK  (([KrajNazwa] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[Kraje] CHECK CONSTRAINT [wzor_nazwy_kraju]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [dodatnia_cena] CHECK  (([DanieCena]>(0)))
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [dodatnia_cena]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [menu_kolejnosc_dat] CHECK  (([MenuDataDo]>[MenuDataOd]))
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [menu_kolejnosc_dat]
GO
ALTER TABLE [dbo].[Miasta]  WITH CHECK ADD  CONSTRAINT [wzor_nazwy_miasta] CHECK  (([MiastoNazwa] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[Miasta] CHECK CONSTRAINT [wzor_nazwy_miasta]
GO
ALTER TABLE [dbo].[PolproduktyWRestauracji]  WITH CHECK ADD  CONSTRAINT [nieujemna_ilosc_pprod] CHECK  (([PWRIloscDostepnych]>=(0)))
GO
ALTER TABLE [dbo].[PolproduktyWRestauracji] CHECK CONSTRAINT [nieujemna_ilosc_pprod]
GO
ALTER TABLE [dbo].[Pracownicy]  WITH CHECK ADD  CONSTRAINT [wzor_imie_pracownika] CHECK  (([PracownikImie] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[Pracownicy] CHECK CONSTRAINT [wzor_imie_pracownika]
GO
ALTER TABLE [dbo].[Pracownicy]  WITH CHECK ADD  CONSTRAINT [wzor_nazwisko_pracownika] CHECK  (([PracownikNazwisko] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[Pracownicy] CHECK CONSTRAINT [wzor_nazwisko_pracownika]
GO
ALTER TABLE [dbo].[Pracownicy]  WITH CHECK ADD  CONSTRAINT [wzor_numeru_pesel] CHECK  (([PracownikPESEL] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Pracownicy] CHECK CONSTRAINT [wzor_numeru_pesel]
GO
ALTER TABLE [dbo].[PracownicyFirm]  WITH CHECK ADD  CONSTRAINT [wzor_imie_pracownika_firmy] CHECK  (([PracownikImie] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[PracownicyFirm] CHECK CONSTRAINT [wzor_imie_pracownika_firmy]
GO
ALTER TABLE [dbo].[PracownicyFirm]  WITH CHECK ADD  CONSTRAINT [wzor_nazwisko_pracownika_firmy] CHECK  (([PracownikNazwisko] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[PracownicyFirm] CHECK CONSTRAINT [wzor_nazwisko_pracownika_firmy]
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo]  WITH CHECK ADD  CONSTRAINT [dodatnia_minimalna_sumaryczna_wartosc_zamowien_w_kwartale] CHECK  (([RKInfoMinSumaWKwartale]>(0)))
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo] CHECK CONSTRAINT [dodatnia_minimalna_sumaryczna_wartosc_zamowien_w_kwartale]
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_rabatu_kwartalnego] CHECK  (([RKInfoAktualneDo]>[RKInfoAktualneOd]))
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo] CHECK CONSTRAINT [kolejnosc_dat_rabatu_kwartalnego]
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo]  WITH CHECK ADD  CONSTRAINT [ulamkowa_wartosc_znizki_4] CHECK  (([RKInfoProcOdKwoty]>=(0) AND [RKInfoProcOdKwoty]<=(1)))
GO
ALTER TABLE [dbo].[RabatKwartalnyInfo] CHECK CONSTRAINT [ulamkowa_wartosc_znizki_4]
GO
ALTER TABLE [dbo].[RabatMiesiecznyHistoria]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_nalicznia_rabatu_miesiecznego] CHECK  (([RMHistDataDo]>=[RMHistDataOd]))
GO
ALTER TABLE [dbo].[RabatMiesiecznyHistoria] CHECK CONSTRAINT [kolejnosc_dat_nalicznia_rabatu_miesiecznego]
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo]  WITH CHECK ADD  CONSTRAINT [dodatnia_ilosc_zamowien_w_miesiacu] CHECK  (([RMInfoIloscZamWMies]>=(1)))
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo] CHECK CONSTRAINT [dodatnia_ilosc_zamowien_w_miesiacu]
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo]  WITH CHECK ADD  CONSTRAINT [dodatnia_minimalna_sumaryczna_wartosc_zamowien_w_miesiacu] CHECK  (([RMInfoMinSumaZamWMies]>(0)))
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo] CHECK CONSTRAINT [dodatnia_minimalna_sumaryczna_wartosc_zamowien_w_miesiacu]
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_rabatu_miesiecznego] CHECK  (([RMInfoAktualneDo]>[RMInfoAktualneOd]))
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo] CHECK CONSTRAINT [kolejnosc_dat_rabatu_miesiecznego]
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo]  WITH CHECK ADD  CONSTRAINT [ulamkowa_wartosc_znizki_3_1] CHECK  (([RMInfoMaksRabat]>=(0) AND [RMInfoMaksRabat]<=(1)))
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo] CHECK CONSTRAINT [ulamkowa_wartosc_znizki_3_1]
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo]  WITH CHECK ADD  CONSTRAINT [ulamkowa_wartosc_znizki_3_2] CHECK  (([RMInfoPrzyrostRabatu]>=(0) AND [RMInfoPrzyrostRabatu]<=(1)))
GO
ALTER TABLE [dbo].[RabatMiesiecznyInfo] CHECK CONSTRAINT [ulamkowa_wartosc_znizki_3_2]
GO
ALTER TABLE [dbo].[RabatStalyInfo]  WITH CHECK ADD  CONSTRAINT [dodatnia_ilosc_zamowien_do_awansu] CHECK  (([RSInfoIloscZamowienDoAwansuRangi]>=(1)))
GO
ALTER TABLE [dbo].[RabatStalyInfo] CHECK CONSTRAINT [dodatnia_ilosc_zamowien_do_awansu]
GO
ALTER TABLE [dbo].[RabatStalyInfo]  WITH CHECK ADD  CONSTRAINT [dodatnia_wartosc_zamowien_do_awansu] CHECK  (([RSInfoMinWartoscZamowienia]>(0)))
GO
ALTER TABLE [dbo].[RabatStalyInfo] CHECK CONSTRAINT [dodatnia_wartosc_zamowien_do_awansu]
GO
ALTER TABLE [dbo].[RabatStalyInfo]  WITH CHECK ADD  CONSTRAINT [kolejnosc_data_rabat_staly] CHECK  (([RSInfoAktualneDo]>[RSInfoAktualneOd]))
GO
ALTER TABLE [dbo].[RabatStalyInfo] CHECK CONSTRAINT [kolejnosc_data_rabat_staly]
GO
ALTER TABLE [dbo].[RabatStalyInfo]  WITH CHECK ADD  CONSTRAINT [ulamkowa_wartosc_znizki_1] CHECK  (([RSInfoRabat]>=(0) AND [RSInfoRabat]<=(1)))
GO
ALTER TABLE [dbo].[RabatStalyInfo] CHECK CONSTRAINT [ulamkowa_wartosc_znizki_1]
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo]  WITH CHECK ADD  CONSTRAINT [dodatni_okres_trwania_rabatu_stalego] CHECK  (([RTInfoOkres]>(0)))
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo] CHECK CONSTRAINT [dodatni_okres_trwania_rabatu_stalego]
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo]  WITH CHECK ADD  CONSTRAINT [dodatnia_kwota_progowa] CHECK  (([RTInfoKwotaProgowa]>(0)))
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo] CHECK CONSTRAINT [dodatnia_kwota_progowa]
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_rabat_tymczasowy] CHECK  (([RTInfoAktualneDo]>[RTInfoAktualneOd]))
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo] CHECK CONSTRAINT [kolejnosc_dat_rabat_tymczasowy]
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo]  WITH CHECK ADD  CONSTRAINT [ulamkowa_wartosc_znizki_2] CHECK  (([RTInfoRabat]>=(0) AND [RTInfoRabat]<=(1)))
GO
ALTER TABLE [dbo].[RabatTymczasowyInfo] CHECK CONSTRAINT [ulamkowa_wartosc_znizki_2]
GO
ALTER TABLE [dbo].[RangaHistoria]  WITH CHECK ADD  CONSTRAINT [dostepne_rangi] CHECK  (([RHRanga]>=(0) AND [RHRanga]<=(2)))
GO
ALTER TABLE [dbo].[RangaHistoria] CHECK CONSTRAINT [dostepne_rangi]
GO
ALTER TABLE [dbo].[Restauracje]  WITH CHECK ADD  CONSTRAINT [phone_number_check_restaurant] CHECK  (([RestauracjaNrTel] like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Restauracje] CHECK CONSTRAINT [phone_number_check_restaurant]
GO
ALTER TABLE [dbo].[Restauracje]  WITH CHECK ADD  CONSTRAINT [wzor_adresu_email_restauracja] CHECK  (([RestauracjaEmail] like '%@%.%'))
GO
ALTER TABLE [dbo].[Restauracje] CHECK CONSTRAINT [wzor_adresu_email_restauracja]
GO
ALTER TABLE [dbo].[Restauracje]  WITH CHECK ADD  CONSTRAINT [wzor_kod_pocztowy_restauracji] CHECK  (([RestauracjaKodPocztowy] like '[0-9][0-9]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Restauracje] CHECK CONSTRAINT [wzor_kod_pocztowy_restauracji]
GO
ALTER TABLE [dbo].[Restauracje]  WITH CHECK ADD  CONSTRAINT [wzor_NIP_restauracji] CHECK  (([RestauracjaNrNIP] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Restauracje] CHECK CONSTRAINT [wzor_NIP_restauracji]
GO
ALTER TABLE [dbo].[SposobPlatnosci]  WITH CHECK ADD  CONSTRAINT [wzor_nazwy_sposobu] CHECK  (([SposobNazwa] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[SposobPlatnosci] CHECK CONSTRAINT [wzor_nazwy_sposobu]
GO
ALTER TABLE [dbo].[Stoliki]  WITH CHECK ADD  CONSTRAINT [dodatnia_maksymalna_ilosc_miejsc] CHECK  (([StolikMaksIloscMiejsc]>(0)))
GO
ALTER TABLE [dbo].[Stoliki] CHECK CONSTRAINT [dodatnia_maksymalna_ilosc_miejsc]
GO
ALTER TABLE [dbo].[StolikiDostepneMiejsca]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_ograniczen_na_miejsca] CHECK  (([SDMDataDo]>=[SDMDataOd] OR [SDMDataDo] IS NULL))
GO
ALTER TABLE [dbo].[StolikiDostepneMiejsca] CHECK CONSTRAINT [kolejnosc_dat_ograniczen_na_miejsca]
GO
ALTER TABLE [dbo].[StolikiDostepneMiejsca]  WITH CHECK ADD  CONSTRAINT [nieujemna_ilosc_miejsc] CHECK  (([SDMIloscDostepnychMiejsc]>=(0)))
GO
ALTER TABLE [dbo].[StolikiDostepneMiejsca] CHECK CONSTRAINT [nieujemna_ilosc_miejsc]
GO
ALTER TABLE [dbo].[SzczegolyZamowienia]  WITH CHECK ADD  CONSTRAINT [dodatnia_ilosc_zamowionych_sztuk] CHECK  (([SZIlosc]>(0)))
GO
ALTER TABLE [dbo].[SzczegolyZamowienia] CHECK CONSTRAINT [dodatnia_ilosc_zamowionych_sztuk]
GO
ALTER TABLE [dbo].[TypDania]  WITH CHECK ADD  CONSTRAINT [wzor_nazwy_typu] CHECK  (([TypNazwa] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[TypDania] CHECK CONSTRAINT [wzor_nazwy_typu]
GO
ALTER TABLE [dbo].[TypZamowienia]  WITH CHECK ADD  CONSTRAINT [wzor_nazwy_typu_zamowienia] CHECK  (([TypZamNazwa] like '[A-Z]%'))
GO
ALTER TABLE [dbo].[TypZamowienia] CHECK CONSTRAINT [wzor_nazwy_typu_zamowienia]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_1] CHECK  (([ZamPreferowanaDataOdbioru]>=[ZamDataZlozenia]))
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [kolejnosc_dat_1]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_2] CHECK  (([ZamDataPlatnosci]>=[ZamDataZlozenia]))
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [kolejnosc_dat_2]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [kolejnosc_dat_3] CHECK  (([ZamDataOdbioru]>=[ZamDataZlozenia]))
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [kolejnosc_dat_3]
GO
ALTER TABLE [dbo].[Zamowienia]  WITH CHECK ADD  CONSTRAINT [wzor_numeru_konta] CHECK  (([ZamNrKonta] like '[0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Zamowienia] CHECK CONSTRAINT [wzor_numeru_konta]
GO
/****** Object:  StoredProcedure [dbo].[change_menu]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[change_menu]
    @restaurantid int
as begin
	declare @menusize int = (select count(*) from Menu WHERE RestauracjaID = @restaurantid)
	declare @todelete int = (select count(*) from DoUsuniecia WHERE RestauracjaID = @restaurantid)
	declare @toadd int = (select count(*) from DoDodania WHERE RestauracjaID = @restaurantid)

	DECLARE @cursor CURSOR
	DECLARE @dishid int
	DECLARE @cost money
	declare @nextchangedate date = DATEADD(week, 2, GETDATE())
	DECLARE @newdomid INT;

	if (@toadd*2 <= @menusize and @todelete*2 <= @menusize )
		select ERROR_MESSAGE() as error
	else


		--deleting
		BEGIN
			SET @cursor = CURSOR FOR (select DanieID from DoUsuniecia WHERE RestauracjaID = @restaurantid)

			OPEN @cursor
			FETCH NEXT FROM @cursor
			INTO @dishid

			WHILE @@FETCH_STATUS = 0
			BEGIN
			    
			  delete from DoUsuniecia
			  where DanieID = @dishid and RestauracjaID = @restaurantid
			                                
			  delete from Menu
			  where DanieID = @dishid and RestauracjaID = @restaurantid

			  declare @domid int = (select max(DOMID) from DaniaOkresyWMenu where DanieID = @dishid and RestauracjaID = @restaurantid)

			  update DaniaOkresyWMenu
			  set DOMDataZdjecia = GETDATE()
			  where DOMID = @domid and RestauracjaID = @restaurantid

			  FETCH NEXT FROM @cursor
			  INTO @dishid
			END

			CLOSE @cursor
			DEALLOCATE @cursor
		END

		--adding

		BEGIN
			SET @cursor = CURSOR FOR (select DanieID, DDCena from DoDodania WHERE RestauracjaID = @restaurantid)

			OPEN @cursor
			FETCH NEXT FROM @cursor
			INTO @dishid, @cost

			WHILE @@FETCH_STATUS = 0
			BEGIN

			  if @dishid in (select DanieID from Menu WHERE RestauracjaID = @restaurantid)
				update Menu
				set MenuDataDo = @nextchangedate
				where DanieID = @dishid and RestauracjaID = @restaurantid
			  else
				set @newdomid = (select max(DOMID) from DaniaOkresyWMenu)
				if (@newdomid is NULL) set @newdomid = 0
				set @newdomid += 1

				insert into Menu
				values (
					@dishid,
					@cost,
					GETDATE(),
					@nextchangedate,
				    @restaurantid
				)

				insert into DaniaOkresyWMenu
				values (
					@newdomid,
					@dishid,
					@cost,
					GETDATE(),
					NULL,
				    @restaurantid
				)

			  FETCH NEXT FROM @cursor
			  INTO @dishid, @cost
			END

			CLOSE @cursor
			DEALLOCATE @cursor
		    
		    delete from DoDodania WHERE RestauracjaID = @restaurantid
		END
end
GO
/****** Object:  StoredProcedure [dbo].[change_menu_in_all_restaurants]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[change_menu_in_all_restaurants]
AS BEGIN
    DECLARE @restaurantid AS INT;
    DECLARE @cursor AS CURSOR;
    SET @cursor = CURSOR FOR (select RestauracjaID FROM Restauracje)

    OPEN @cursor
    FETCH NEXT FROM @cursor
	INTO @restaurantid

	WHILE @@FETCH_STATUS = 0
	BEGIN
        EXEC dbo.change_menu @restaurantid

        FETCH NEXT FROM @cursor
        INTO @restaurantid
	END

	CLOSE @cursor
	DEALLOCATE @cursor
END
GO
/****** Object:  StoredProcedure [dbo].[dodaj_klienta_indywidualnego]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[dodaj_klienta_indywidualnego]
	@nrTel varchar(50),
	@email varchar(50),
	@name varchar(50),
	@surname varchar(50),
	@restaurantid int
as begin
	declare @maxindex int = (select max(KlientID) from Klient) + 1
	IF @maxindex IS NULL SET @maxindex = 1
	
	insert into Klient
	values (
			@maxindex,
			@nrTel,
			@email,
			GETDATE()
	)

	insert into KlientRestauracji
	values (
	        @maxindex,
	        @restaurantid
           )

	insert into KlientIndywidualny
	values (
			@maxindex,
			@name,
			@surname
	)

	declare @discountid int = (select RSInfoRabatID
									from RabatStalyInfo
									where (RSInfoAktualneDo >= GETDATE() or RSInfoAktualneDo IS NULL) and
									RSInfoAktualneOd <= GETDATE() AND RestauracjaID = @restaurantid)

	IF @discountid IS NULL SET @discountid = 1
	
	insert into RangaHistoria
	values (
			@maxindex,
			@discountid,
			0,
			GETDATE(),
			NULL
	)
end
GO
/****** Object:  StoredProcedure [dbo].[dodaj_nowe_obostrzenie]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodaj_nowe_obostrzenie] @tables StolikZObostrzeniem READONLY
AS BEGIN
	IF EXISTS (SELECT StolikID FROM dbo.Stoliki s
			   WHERE StolikMaksIloscMiejsc < (SELECT IloscMiejsc FROM @tables sub
											  WHERE sub.StolikID = s.StolikID
											 )
			   )
		SELECT ERROR_MESSAGE() AS 'jeden z podanych stolików nie może mieć tak dużej liczby dostępnych miejsc'
	ELSE BEGIN
		DECLARE @cursor CURSOR 
		DECLARE @tableid INT
		DECLARE @seats INT 

		SET @cursor = CURSOR FOR 
		(SELECT StolikID, IloscMiejsc FROM @tables)

		OPEN @cursor
        FETCH NEXT FROM @cursor
        INTO @tableid, @seats

        WHILE @@FETCH_STATUS = 0
		BEGIN
		   DECLARE @id INT = (SELECT MAX(SDMID) FROM dbo.StolikiDostepneMiejsca)
		   IF @id IS NULL SET @id = 0
		   SET @id += 1

		   UPDATE dbo.StolikiDostepneMiejsca
		   SET SDMDataDo = GETDATE()
		   WHERE SDMDataDo IS NULL AND StolikID = @tableid

		   INSERT INTO dbo.StolikiDostepneMiejsca
		   (
		       SDMID,
		       StolikID,
		       SDMDataOd,
		       SDMDataDo,
		       SDMIloscDostepnychMiejsc
		   )
		   VALUES
		   (   @id,         -- SDMID - int
		       @tableid,         -- StolikID - int
		       GETDATE(), -- SDMDataOd - date
		       NULL, -- SDMDataDo - date
		       @seats          -- SDMIloscDostepnychMiejsc - int
		       )

		  FETCH NEXT FROM @cursor
          INTO @tableid, @seats
		END

		CLOSE @cursor
		DEALLOCATE @cursor

	END 
END 
GO
/****** Object:  StoredProcedure [dbo].[dodaj_restauracje]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodaj_restauracje] 
	@name varchar(50),
	@address varchar(50),
	@cityid int,
	@postalcode varchar(50),
	@nip varchar(50),
	@email varchar(50),
	@phone varchar(50),
	@tables StolikiPrzezListeMiejsc READONLY
AS BEGIN
     DECLARE @id INT = (SELECT MAX(RestauracjaId) FROM dbo.Restauracje)  
	 IF @id IS NULL SET @id = 0
	 SET @id += 1

	 IF @cityid NOT IN (SELECT MiastoID FROM dbo.Miasta)
		SELECT ERROR_MESSAGE() AS 'nie ma takiego miasta'
	 ELSE BEGIN
		INSERT INTO dbo.Restauracje
		(
		    RestauracjaID,
		    RestauracjaNazwa,
		    RestauracjaAdres,
		    RestauracjaMiasto,
		    RestauracjaKodPocztowy,
		    RestauracjaNrNIP,
		    RestauracjaEmail,
		    RestauracjaNrTel
		)
		VALUES
		(   @id,  -- RestauracjaID - int
		    @name, -- RestauracjaNazwa - varchar(50)
		    @address, -- RestauracjaAdres - varchar(50)
		    @cityid,  -- RestauracjaMiasto - int
		    @postalcode, -- RestauracjaKodPocztowy - varchar(50)
		    @nip, -- RestauracjaNrNIP - varchar(50)
		    @email, -- RestauracjaEmail - varchar(50)
		    @phone  -- RestauracjaNrTel - varchar(50)
		    )

		DECLARE @cursor CURSOR 
		DECLARE @seats INT 

		SET @cursor = CURSOR FOR 
		(SELECT IloscMiejsc FROM @tables)

		OPEN @cursor
        FETCH NEXT FROM @cursor
        INTO @seats

		DECLARE @newtableid INT = (SELECT MAX(StolikID) FROM dbo.Stoliki)
		IF @newtableid IS NULL SET @newtableid = 0
		SET @newtableid += 1

        WHILE @@FETCH_STATUS = 0
		BEGIN
		   INSERT INTO dbo.Stoliki
		   (
		       StolikID,
		       RestauracjaID,
		       StolikMaksIloscMiejsc
		   )
		   VALUES
		   (   @newtableid, -- StolikID - int
		       @id, -- RestauracjaID - int
		       @seats  -- StolikMaksIloscMiejsc - int
		       )
          SET @newtableid += 1
		  FETCH NEXT FROM @cursor
          INTO @seats
		END

		CLOSE @cursor
		DEALLOCATE @cursor
	 END 
END
GO
/****** Object:  StoredProcedure [dbo].[dodaj_rezerwacje_bez_zamowienia]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodaj_rezerwacje_bez_zamowienia]
@clientid INT,
@dateoofreservation smalldatetime,
@employeelist ListaPracownikowFirm READONLY,
@tablelist ListaStolikow READONLY
AS
     BEGIN
         IF dbo.czyJestFirma(@clientid) = 1
             BEGIN
                 DECLARE @amountoftables INT = (SELECT COUNT(*) FROM @tablelist)
                 DECLARE @amountofactivetables INT = (SELECT COUNT(DISTINCT DS.StolikID)
                                                      FROM @tablelist TL
                                                      INNER JOIN DostepneStoliki DS ON DS.StolikID = TL.StolikID
                                                      )

                 IF @amountoftables = @amountofactivetables
                     BEGIN
                         DECLARE @rezid INT = (SELECT MAX(RezID) FROM Rezerwacje) + 1
                         IF @rezid IS NULL SET @rezid = 1

                         INSERT INTO Rezerwacje
                                VALUES(
                                    @rezid,
                                    @dateoofreservation
                                )

                        DECLARE @cursor CURSOR
                        DECLARE @tableid INT;
                        SET @cursor = CURSOR FOR (SELECT StolikID FROM @tablelist)

                        OPEN @cursor
                        FETCH NEXT FROM @cursor
                        INTO @tableid

                        WHILE @@FETCH_STATUS = 0
                        BEGIN
                            DECLARE @sdmid INT = (SELECT DISTINCT SDMID FROM StolikiDostepneMiejsca
                                                  WHERE StolikID = @tableid AND SDMDataOd <= @dateoofreservation 
                                                  AND (SDMDataDo IS NULL OR @dateoofreservation <= SDMDataDo)
                                                 )

                            INSERT INTO StolikiRezerwacje
                            VALUES(
                                    @sdmid,
                                    @rezid
                                )

                            FETCH NEXT FROM @cursor
                            INTO @tableid
                        END
                        CLOSE @cursor
                        DEALLOCATE @cursor

                        INSERT INTO RezerwacjeFirmBezZamowienia
                                VALUES (
                                    @rezid,
                                    @clientid
                                    )

                         If EXISTS (SELECT * FROM @employeelist)
                            BEGIN
                                DECLARE @employeeid INT;
                                SET @cursor = CURSOR FOR (SELECT PracownikID FROM @employeelist)

                                OPEN @cursor
                                FETCH NEXT FROM @cursor
                                INTO @employeeid

                                WHILE @@FETCH_STATUS = 0
                                    BEGIN
                                        INSERT INTO ListyPracownikowDoRezerwacji
                                        VALUES(
                                                @rezid,
                                                @employeeid
                                            )

                                        FETCH NEXT FROM @cursor
                                        INTO @employeeid
                                    END
                                CLOSE @cursor
                                DEALLOCATE @cursor
                            END
                     END
                 ELSE
                    BEGIN
                        SELECT ERROR_MESSAGE() AS 'nie wszytkie stoliki z rezerwacji sa aktywne'
                    END
             END
         ELSE
            BEGIN
                SELECT ERROR_MESSAGE() AS 'tylko firma moze skladac rezerwacje bez zamowienia'
            END
     END
GO
/****** Object:  StoredProcedure [dbo].[dodaj_rezerwacje_z_zamowieniem]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodaj_rezerwacje_z_zamowieniem]
	@clientid INT,
	@preffereddate DATE,
	@paidnow BIT,
	@receivednow BIT,
	@type INT,
	@paymenttype INT,
	@account VARCHAR(50),
	@employee INT,
	@dishesfrommenu ListaDan READONLY,
	@restaurantid INT,
	@dateoofreservation smalldatetime,
    @employeelist ListaPracownikowFirm  READONLY,
    @tablelist ListaStolikow READONLY
AS
    BEGIN
        IF dbo.czyJestFirma(@clientid) = 1
            BEGIN
                EXEC dbo.dodaj_zamowienie @clientid, @preffereddate, @paidnow,@receivednow,
                    @type, @paymenttype, @account, @employee, @dishesfrommenu, @restaurantid

                EXEC dodaj_rezerwacje_bez_zamowienia @clientid, @dateoofreservation, @employeelist, @tablelist

                DECLARE @rezid INT = (SELECT MAX(RezID) FROM Rezerwacje)
                DECLARE @zamid INT = (SELECT MAX(ZamID) FROM Zamowienia)

                INSERT INTO RezerwacjeDoZamowienia
                VALUES(
                       @rezid,
                       @zamid
                      )
            END
        ELSE
            BEGIN
                -- mozna rabat dokladniej z rabatami
                DECLARE @valueoforder decimal(18, 10) = (SELECT SUM(M.DanieCena * DFM.IloscZamowionych)
                                                         FROM @dishesfrommenu DFM
                                                         INNER JOIN Menu M ON M.DanieID = DFM.DanieID
                                                        )

                IF dbo.czyKlientMozeRezerwowacPrzezInternet(@clientid, @valueoforder) = 1
                    BEGIN
                        EXEC dbo.dodaj_zamowienie @clientid, @preffereddate, @paidnow,@receivednow,
                    @type, @paymenttype, @account, @employee, @dishesfrommenu, @restaurantid

                        DECLARE @amountoftables INT = (SELECT COUNT(*) FROM @tablelist)
                        DECLARE @amountofactivetables INT = (SELECT COUNT(DISTINCT DS.StolikID)
                                                      FROM @tablelist TL
                                                      INNER JOIN DostepneStoliki DS ON DS.StolikID = TL.StolikID
                                                      )

                         IF @amountoftables = @amountofactivetables
                             BEGIN
                                 DECLARE @rezid2 INT = (SELECT MAX(RezID) FROM Rezerwacje) + 1
                                 IF @rezid2 IS NULL SET @rezid2 = 1

                                 INSERT INTO Rezerwacje
                                        VALUES(
                                            @rezid2,
                                            @dateoofreservation
                                        )

                                DECLARE @zamid2 INT = (SELECT MAX(ZamID) FROM Zamowienia)

                                INSERT INTO RezerwacjeDoZamowienia
                                VALUES(
                                       @rezid2,
                                       @zamid2
                                      )

                                DECLARE @cursor CURSOR
                                DECLARE @tableid INT;
                                SET @cursor = CURSOR FOR (SELECT StolikID FROM @tablelist)

                                OPEN @cursor
                                FETCH NEXT FROM @cursor
                                INTO @tableid

                                WHILE @@FETCH_STATUS = 0
                                BEGIN
                                DECLARE @sdmid INT = (SELECT DISTINCT SDMID FROM StolikiDostepneMiejsca
                                                      WHERE StolikID = @tableid AND SDMDataOd <= @dateoofreservation 
                                                      AND (SDMDataDo IS NULL OR @dateoofreservation <= SDMDataDo)
                                                     )

                                    INSERT INTO StolikiRezerwacje
                                    VALUES(
                                            @sdmid,
                                            @rezid2
                                        )

                                    FETCH NEXT FROM @cursor
                                    INTO @tableid
                                END
                                CLOSE @cursor
                                DEALLOCATE @cursor
                             END
                         ELSE
                            BEGIN
                                SELECT ERROR_MESSAGE() AS 'nie wszytkie stoliki z rezerwacji sa aktywne'
                            END
                    END
                ELSE
                    BEGIN
                        SELECT ERROR_MESSAGE() AS 'Podany Klient Indywidualny nie spelnia warunkow do rezerwacji przez internet'
                    END
            END
    END
GO
/****** Object:  StoredProcedure [dbo].[dodaj_zamowienie]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodaj_zamowienie]
	@client INT,
	@preffereddate DATE,
	@paidnow BIT,
	@receivednow BIT,
	@type INT,
	@paymenttype INT,
	@account VARCHAR(50),
	@employee INT,
	@dishesfrommenu ListaDan READONLY,
	@restaurantid INT
AS 
BEGIN
	declare @dateofpayment date 
	declare @receiveddate date
	declare @id INT
    DECLARE @amountofdishestoadd INT = (SELECT COUNT(*) FROM @dishesfrommenu)
	set @id = (select max(ZamID) from Zamowienia)+1
	IF @id IS NULL SET @id = 1

	if @paidnow = 1
		set @dateofpayment = GETDATE()
	ELSE
		SET @dateofpayment = NULL

	if @receivednow = 1
		set @receiveddate = GETDATE()
	ELSE
		SET @receiveddate = NULL

	IF @client NOT IN (SELECT KlientID FROM dbo.KlientRestauracji WHERE RestauracjaID = @restaurantid)
		SELECT ERROR_MESSAGE() AS 'ten klient nie nalzey do tej restauracji'
	ELSE IF @employee NOT IN (SELECT PracownikID FROM Pracownicy WHERE RestauracjaID = @restaurantid)
		SELECT ERROR_MESSAGE() AS 'dana restauracja nie ma takiego pracownika'
	ELSE IF  @preffereddate < GETDATE()
		SELECT ERROR_MESSAGE() AS 'preferowana data odbioru nie może być wcześniejsza niż obecna data'
	ELSE IF  @type NOT IN (SELECT TypZamID FROM TypZamowienia)
		SELECT ERROR_MESSAGE() AS 'nie ma takiego typu zamówienia'
	ELSE IF  @paymenttype NOT IN (SELECT SposobID FROM SposobPlatnosci)
		SELECT ERROR_MESSAGE() AS 'nie ma takiego sposobu płatności'
	ELSE IF  (@dateofpayment IS NOT NULL AND @paymenttype IS NULL)
		select ERROR_MESSAGE() as 'ustawienie daty zapłaty wymaga podania typu płatności'
	ELSE IF @amountofdishestoadd != (SELECT COUNT(*) FROM @dishesfrommenu 
														WHERE 
															 DanieID IN (SELECT DanieID FROM dbo.Menu) )
		select ERROR_MESSAGE() as 'jednego z wybranych dań nie ma w menu'
	ELSE IF (@preffereddate IS NOT NULL AND @amountofdishestoadd != (SELECT COUNT(*) FROM @dishesfrommenu 
														INNER JOIN dbo.Menu ON Menu.DanieID = [@dishesfrommenu].DanieID
														WHERE @preffereddate BETWEEN MenuDataOd AND MenuDataDo))
		select ERROR_MESSAGE() as 'jednego z dań nie można zamówić w podanym okresie'
	ELSE
	    BEGIN
                insert into Zamowienia
                values (
                    @id,
                    @client,
                    @preffereddate,
                    @preffereddate,
                    @preffereddate,
                    @preffereddate, -- na potrzby testowania rabatow
                    @type,
                    @paymenttype,
                    @account,
                    @employee,
                    @restaurantid
                )
                
            DECLARE @cursor CURSOR
            DECLARE @dishid int
            DECLARE @amount int
                BEGIN
                    SET @cursor = CURSOR FOR (select DanieID, IloscZamowionych from @dishesfrommenu)   
        
                    OPEN @cursor 
                    FETCH NEXT FROM @cursor 
                    INTO @dishid, @amount
        
                    WHILE @@FETCH_STATUS = 0
                    BEGIN
                      DECLARE @fromdate DATE
                      DECLARE @todate DATE
                      SELECT @fromdate = MenuDataOd, @todate = MenuDataDo
                       FROM Menu
                       WHERE DanieID = @dishid
        
        
                      
                      INSERT INTO SzczegolyZamowienia
                      VALUES (
                           @id,
                           @dishid,
                           @amount
                      )
        
                      FETCH NEXT FROM @cursor 
                      INTO @dishid, @amount
                    END
        
                    CLOSE @cursor 
                    DEALLOCATE @cursor
                END
        
             IF @client IN (SELECT KindID FROM KlientIndywidualny)
               BEGIN
                    EXEC dbo.update_rangi @client, @restaurantid
                    EXEC dbo.update_rabatu_tymczasowego @client, @restaurantid
               END

    END
	
END
GO
/****** Object:  StoredProcedure [dbo].[dodajFirme]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodajFirme]
    @companyName varchar(50),
    @nrTel varchar(50),
    @email varchar(50),
    @companyAddress varchar(50),
    @companyCityID INT,
    @companyPostalCode varchar(50),
    @companyFax varchar(50),
    @companyNIPNumber varchar(50),
    @restaurantid INT,
    @companyWantCollectiveInvoice bit
    AS
        BEGIN
            IF @companyCityID IN (SELECT MiastoID FROM Miasta)
                BEGIN
                    DECLARE @firmaid INT = (SELECT MAX(FirmaID) FROM Firma) + 1
                    IF @firmaid IS NULL SET @firmaid = 1

                    
                    insert into Klient
                    values (
                        @firmaid,
                        @nrTel,
                        @email,
                        GETDATE()
                    )
                    
                    insert into KlientRestauracji
                    values (
                            @firmaid,
                            @restaurantid
                            )
                    
                    INSERT INTO FIRMA(FIRMAID, FirmaNazwa, FirmaAdres, FirmaMiastoID, FirmaKodPocztowy, FirmaFax, FirmaNrNIP, FirmaFakturaMiesieczna)
                    VALUES(@firmaid, @companyName, @companyAddress, @companyCityID, @companyPostalCode, @companyFax, @companyNIPNumber, @companyWantCollectiveInvoice)
                    
                    declare @discountid int = (select RMInfoRabatID
                                                from RabatMiesiecznyInfo
                                                where (RMInfoAktualneDo >= GETDATE() or RMInfoAktualneDo IS NULL) and
                                                RMInfoAktualneOd <= GETDATE() AND RestauracjaID = @restaurantid)
                    
                    DECLARE @rabatid INT = (SELECT MAX(RabatID) FROM RabatMiesiecznyHistoria) + 1
                    IF @rabatid IS NULL SET @rabatid = 1
                    
                    insert into RabatMiesiecznyHistoria
                    values (
                            @rabatid,
                            @firmaid,
                            @discountid,
                            DATEADD(MONTH, -3, GETDATE()),
                            NULL
                    )
                    
                END
            ELSE
                BEGIN
                    PRINT 'companyCityID not in Miasta'
                END
        END
GO
/****** Object:  StoredProcedure [dbo].[dodajMiasto]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dodajMiasto]
    @cityName varchar(50),
    @cityCountry varchar(50)
    AS
        BEGIN
            declare @newid int;
            IF @cityCountry NOT IN (SELECT KrajNazwa FROM Kraje)
                BEGIN
                    set @newid = (select max(KrajID) from Kraje)
				    if (@newid is NULL) set @newid = 0
				    set @newid += 1
                    INSERT INTO KRAJE(KrajID, KrajNazwa)
                    VALUES(@newid, @cityCountry)
                END
            DECLARE @countryID AS INT = (SELECT KrajID FROM KRAJE WHERE KrajNazwa = @cityCountry)
            set @newid = (select max(MiastoID) from Miasta)
			if (@newid is NULL) set @newid = 0
			set @newid += 1
            INSERT INTO Miasta(MiastoID, MiastoNazwa, KrajID)
            VALUES(@newid, @cityName, @countryID)
        END
GO
/****** Object:  StoredProcedure [dbo].[update_rabatu_tymczasowego]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[update_rabatu_tymczasowego] @clientid int, @restaurantid int
as begin
	declare @ordersvaluesum money =
	                             (select SUM(SZ.SZIlosc * DOWM.DOMCena * dbo.rabat_staly_indywidualnego_dla_daty(Z.ZamDataZlozenia, @clientid) *
	                                         dbo.rabat_tymczasowy_indywidualnego_dla_daty(Z.ZamDataZlozenia, @clientid))
								     from SzczegolyZamowienia SZ
	                                 inner join Dania D on D.DanieID = SZ.DanieID
									 inner join Zamowienia Z on SZ.ZamID = Z.ZamID
	                                 inner join DaniaOkresyWMenu DOWM on D.DanieID = DOWM.DanieID
	                                 WHERE DOWM.DOMDataWstawienia <= Z.ZamDataZlozenia AND
	                                 (DOWM.DOMDataZdjecia IS NULL OR DOWM.DOMDataZdjecia >= ZamDataZlozenia)
									 AND Z.ZamPrzezKlient = @clientid)



	DECLARE @cursor CURSOR;
	DECLARE @discountid int;
	BEGIN
		SET @cursor = CURSOR FOR (select RTInfoRabatID from AktualnyRabatTymczasowy WHERE RestauracjaID = @restaurantid)

		OPEN @cursor 
		FETCH NEXT FROM @cursor 
		INTO @discountid

		WHILE @@FETCH_STATUS = 0
		BEGIN
				
				declare @givendiscounts int = (select count(*) 
											   from PrzyznanyRabatTymczasowy
											   where RabatID = @discountid)
				declare @bordervalue money = (select RTInfoKwotaProgowa
										from RabatTymczasowyInfo
										where RTInfoRabatID = @discountid)
				
				declare @sum money = @ordersvaluesum
				declare @count int = 0
				
				while @sum - @bordervalue >= 0
				begin
					set @sum -= @bordervalue
					set @count += 1
				end

				declare @maxindex int = (select max(PRTID) from PrzyznanyRabatTymczasowy)
				IF @maxindex IS NULL SET @maxindex = 0

				while @count > @givendiscounts
				begin
					set @maxindex += 1
					insert into PrzyznanyRabatTymczasowy
					values (
							@maxindex,
							@discountid,
							@clientid,
							GETDATE()
					)
					set @givendiscounts += 1
				end
					
		  FETCH NEXT FROM @cursor 
		  INTO @discountid 
		END

		CLOSE @cursor 
		DEALLOCATE @cursor
	END
end
GO
/****** Object:  StoredProcedure [dbo].[update_rangi]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[update_rangi] @clientid INT, @restaurantid INT
AS BEGIN
    -- u mnie trzeba zadekrlarowac przed wszystkim zeby działało
    -- potzebuje id restauracxji
	declare @currentrank int = (select MAX(RHRanga)
								from RangaHistoria RH
								where KIndID = @clientid and
									  RHDataUmorzenia is NULL AND (SELECT RestauracjaID FROM RabatStalyInfo WHERE RSInfoRabatID = RH.RabatID) = @restaurantid)

	declare @minamount as int;
    declare @minvalue as money 
        
    select @minamount = RSInfoIloscZamowienDoAwansuRangi, @minvalue = RSInfoMinWartoscZamowienia
	from RabatStalyInfo
	where RSInfoAktualneOd <= GETDATE() and
	((RSInfoAktualneDo is NULL or RSInfoAktualneDo >= GETDATE())) AND RestauracjaID = @restaurantid
    
	DECLARE @currentamount INT = (SELECT COUNT(*) FROM
	                             (SELECT Z.ZamID
								     FROM SzczegolyZamowienia SZ
	                                 INNER JOIN Dania D ON D.DanieID = SZ.DanieID
									 INNER JOIN Zamowienia Z ON SZ.ZamID = Z.ZamID
	                                 INNER JOIN DaniaOkresyWMenu DOWM ON D.DanieID = DOWM.DanieID
	                                 WHERE DOWM.DOMDataWstawienia <= Z.ZamDataZlozenia AND
	                                 (DOWM.DOMDataZdjecia IS NULL OR DOWM.DOMDataZdjecia >= ZamDataZlozenia)
									 AND Z.ZamPrzezKlient = @clientid
									 GROUP BY Z.ZamID
									 HAVING 
	                                       SUM(SZ.SZIlosc * DOWM.DOMCena * dbo.rabat_staly_indywidualnego_dla_daty(Z.ZamDataZlozenia, @clientid) *
	                                         dbo.rabat_tymczasowy_indywidualnego_dla_daty(Z.ZamDataZlozenia, @clientid))  > @minvalue) AS alamakota)
                                    
    
    IF @currentamount IS NULL SET @currentamount = 0

    DECLARE @currentdiscountid INT = (SELECT RSInfoRabatID
										FROM RabatStalyInfo
										WHERE ((RSInfoAktualneDo IS NULL OR RSInfoAktualneDo >= GETDATE()) AND RestauracjaID = @restaurantid) AND
										RSInfoAktualneOd <= GETDATE())

	IF @currentrank < 2
	    BEGIN
            IF FLOOR((@currentamount)/ @minamount) > @currentrank
            BEGIN
                UPDATE RangaHistoria
                SET RHDataUmorzenia = GETDATE()
                WHERE RHDataUmorzenia IS NULL AND KIndID = @clientid
                
                SELECT @currentrank + 1 
        
                INSERT INTO RangaHistoria
                VALUES (
                        @clientid,
                        @currentdiscountid,
                        @currentrank + 1,
                        GETDATE(),
                        NULL
                    )
            END
		END
			
END
GO
/****** Object:  StoredProcedure [dbo].[usunDanieZMenu]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usunDanieZMenu]
    @danieid INT
    AS
        BEGIN
            IF @danieid IN (SELECT DanieID
                            FROM Menu)
                BEGIN
                    DELETE FROM Menu
                    WHERE DanieID = @danieid
                END
        END
GO
/****** Object:  StoredProcedure [dbo].[wyczysc_klientow]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[wyczysc_klientow]
AS
BEGIN
    DELETE FROM dbo.RezerwacjeDoZamowienia
    DELETE PracownicyFirm
    DELETE FROM dbo.RezerwacjeFirmBezZamowienia
    DELETE FROM dbo.ListyPracownikowDoRezerwacji
    DELETE FROM dbo.StolikiRezerwacje
	DELETE FROM dbo.RangaHistoria
	DELETE FROM dbo.PrzyznanyRabatTymczasowy
	DELETE FROM dbo.KlientIndywidualny
	DELETE FROM dbo.RabatKwartalnyHitoria
	DELETE FROM dbo.RabatMiesiecznyHistoria
	DELETE FROM dbo.Firma
	DELETE FROM dbo.SzczegolyZamowienia
	DELETE FROM dbo.Zamowienia
	DELETE FROM dbo.KlientRestauracji
	DELETE FROM dbo.Klient
    DELETE FROM Rezerwacje
end
GO
/****** Object:  StoredProcedure [dbo].[zaktualizuj_dostepnosc_owocow_morza]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [Job wywolywany przez Agenta na serwerze co poniedziałek]
CREATE PROCEDURE [dbo].[zaktualizuj_dostepnosc_owocow_morza]
AS
    BEGIN
        DECLARE @seafoodid INT;
        DECLARE @MyCursor CURSOR;

        -- Statement That Returns Date Of Next Monday
        DECLARE @NextDayID INT  = 0 -- 0=Mon, 1=Tue, 2 = Wed, ..., 5=Sat, 6=Sun
        DECLARE @nextMonday date = (SELECT DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, GETDATE()) / 7) * 7 + 7, @NextDayID) AS NextDay)

        SET @MyCursor = CURSOR FOR
        SELECT OwoceMorza.DanieID
        FROM OwoceMorza
        INNER JOIN Menu M on OwoceMorza.DanieID = M.DanieID

        OPEN @MyCursor
        FETCH NEXT FROM @MyCursor
        INTO @seafoodid

        WHILE @@FETCH_STATUS = 0
                BEGIN
                    -- Bo Job Jest Wywoływany Co Poniedziałek
                    UPDATE Menu
                    SET MenuDataOd = @nextMonday,
                        MenuDataDo = DATEADD(WEEK, 1, @nextMonday)
                    WHERE DanieID = @seafoodid

                    FETCH NEXT FROM @MyCursor
                    INTO @seafoodid
                END;

            CLOSE @MyCursor ;
            DEALLOCATE @MyCursor;
    END
GO
/****** Object:  StoredProcedure [dbo].[zaktualizuj_statystyki_firmy_miesiac]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[zaktualizuj_statystyki_firmy_miesiac]
	@date date
AS
    BEGIN
        declare @minSumZamWMies decimal(18, 10)
        declare @minIloscZamWMies INT
        declare @discountid INT

        DECLARE @IloscZamowien INT
        DECLARE @SumaZamowien decimal(18, 10)

        declare @startdate date = DATEADD(MONTH, -1, @date)

        DECLARE @FirmaIDTemp INT;
        DECLARE @MyCursor CURSOR;

        SET @MyCursor = CURSOR FOR
        SELECT FirmaID
        FROM Firma

        OPEN @MyCursor
        FETCH NEXT FROM @MyCursor
        INTO @FirmaIDTemp

        WHILE @@FETCH_STATUS = 0
                BEGIN
                    SELECT  @minSumZamWMies = RMInfoMinSumaZamWMies, @minIloscZamWMies = RMInfoIloscZamWMies, @discountid = RMInfoRabatID
                    FROM    dbo.RabatMiesiecznyInfo
                    WHERE   (RMInfoAktualneOd <= @date) AND (RMInfoAktualneDo IS NULL OR
                            @date < RMInfoAktualneDo) AND RestauracjaID =  (SELECT RestauracjaID
                                                                            FROM KlientRestauracji
                                                                            WHERE KlientID = @FirmaIDTemp)

                    SELECT @IloscZamowien = COUNT(Z.ZamID), @SumaZamowien = SUM(WZF.ZRabatemKwartalnym)
                    FROM WartoscZamowieniaFirmy WZF
                    INNER JOIN Zamowienia Z ON Z.ZamID = WZF.IDZamowienia
                    WHERE Z.ZamPrzezKlient = @FirmaIDTemp and  @startdate <= Z.ZamDataZlozenia
                            and Z.ZamDataZlozenia < @date

                    IF @IloscZamowien IS NULL OR @SumaZamowien IS NULL
                        BEGIN
                            SET @IloscZamowien = 0
                            SET @SumaZamowien = 0
                        END
                    
                    SELECT @FirmaIDTemp, @SumaZamowien, @minSumZamWMies, @IloscZamowien, @minIloscZamWMies

                    IF NOT (@SumaZamowien >= @minSumZamWMies AND @IloscZamowien >= @minIloscZamWMies)
                        BEGIN
                           UPDATE RabatMiesiecznyHistoria
                           SET RMHistDataDo = @date
                           WHERE RMHistDataDo IS NULL AND FirmaID = @FirmaIDTemp

                           DECLARE @id AS INT = (SELECT MAX(RMHID) FROM RabatMiesiecznyHistoria) + 1
                           IF @id IS NULL SET @id = 1

                           INSERT INTO RabatMiesiecznyHistoria
                           VALUES(@id, @FirmaIDTemp, @discountid, @date, NULL)
                        END
                    FETCH NEXT FROM @MyCursor
                    INTO @FirmaIDTemp
                END;

            CLOSE @MyCursor ;
            DEALLOCATE @MyCursor;
	END
GO
/****** Object:  StoredProcedure [dbo].[zaktualizujStatystykiFirmyKwartal]    Script Date: 24.01.2021 23:43:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[zaktualizujStatystykiFirmyKwartal]
	@date date
AS
    BEGIN
        declare @minSumZamWKwartale decimal(18, 10)
        declare @discountid INT

        DECLARE @SumaZamowien INT

        declare @startdate date = DATEADD(QUARTER , -1, @date)

        DECLARE @FirmaIDTemp INT;
        DECLARE @MyCursor CURSOR;

        SET @MyCursor = CURSOR FOR
        SELECT FirmaID
        FROM Firma

        OPEN @MyCursor
        FETCH NEXT FROM @MyCursor
        INTO @FirmaIDTemp

        WHILE @@FETCH_STATUS = 0
                BEGIN
                    SELECT  @minSumZamWKwartale = RKInfoMinSumaWKwartale, @discountid = RKInfoID
                    FROM    dbo.RabatKwartalnyInfo
                    WHERE   (RKInfoAktualneOd <= @date) AND (RKInfoAktualneDo IS NULL OR -- bo jak aktualne do dzisiaj to otworzylismy juz nowy
                            @date < RKInfoAktualneDo) AND RestauracjaID =  (SELECT RestauracjaID
                                                                            FROM KlientRestauracji
                                                                            WHERE KlientID = @FirmaIDTemp)

                    SELECT @SumaZamowien = SUM(WZF.ZRabatemMiesiecznym)
                    FROM WartoscZamowieniaFirmy WZF
                    INNER JOIN Zamowienia Z ON Z.ZamID = WZF.IDZamowienia
                    WHERE Z.ZamPrzezKlient = @FirmaIDTemp and  @startdate <= Z.ZamDataZlozenia
                            and Z.ZamDataZlozenia < @date

                    DECLARE @date2 date = DATEADD(QUARTER, -1, @date)

                    SET @SumaZamowien -= dbo.rabat_kwartalny_dla_daty(@date2, @FirmaIDTemp)

                    IF @SumaZamowien IS NULL
                        BEGIN
                            SET @SumaZamowien = 0
                        END

                    IF @SumaZamowien >= @minSumZamWKwartale
                        BEGIN
                           DECLARE @id AS INT = (SELECT MAX(RKHID) FROM RabatKwartalnyHitoria)
                           IF @id IS NULL SET @id = 1

                           INSERT INTO RabatKwartalnyHitoria
                           VALUES(@id, @FirmaIDTemp, @discountid, @date)
                        END
                    
                    FETCH NEXT FROM @MyCursor
                    INTO @FirmaIDTemp
                END;

            CLOSE @MyCursor ;
            DEALLOCATE @MyCursor;
        END;
GO
USE [master]
GO
ALTER DATABASE [u_pastuszk] SET  READ_WRITE 
GO
