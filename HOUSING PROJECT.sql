SELECT *
FROM [Housing Data Cleaning].DBO.Housing


--Start convert SaleDate in to Date format only and removing time

SELECT SaleDate
FROM [Housing Data Cleaning].DBO.Housing

select SaleDateConverted, CONVERT(DATE, SaleDate)
FROM [Housing Data Cleaning].DBO.Housing

UPDATE Housing
SET SaleDate = CONVERT(DATE, SaleDate)


ALTER TABLE Housing
ADD SaleDateConverted Date;

UPDATE Housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--Populate PropertyAdress data
 SELECT *
 From [Housing Data Cleaning].dbo.Housing
 where PropertyAddress is null

 --when fist parcelid = second parcel id, and when first uniqueid <> second uniqueid then populate the null a.propertyAddress

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
 From [Housing Data Cleaning].dbo.Housing a
 JOIN [Housing Data Cleaning].dbo.Housing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
From [Housing Data Cleaning].dbo.Housing a
 JOIN [Housing Data Cleaning].dbo.Housing b
      on a.ParcelID = b.ParcelID
	  and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Propertyaddress in to individual columns (Address , City, State)

SELECT *
FROM [Housing Data Cleaning].DBO.Housing

SELECT
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)
 ,PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
FROM [Housing Data Cleaning].DBO.Housing

ALTER TABLE Housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Housing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

ALTER TABLE Housing
ADD PropertySplitCity Nvarchar(255);

UPDATE Housing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)

--Breaking out Owneraddress in to individual columns (Address , City, State)

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 ,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Housing Data Cleaning].DBO.Housing

ALTER TABLE Housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Housing
ADD OwnerSplitState Nvarchar(255);

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes Or No in 'Sold as vacant field'

SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Housing Data Cleaning].DBO.Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE when SoldAsVacant= 'Y'THEN 'YES'
      WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM [Housing Data Cleaning].DBO.Housing

UPDATE Housing
SET SoldAsVacant = CASE when SoldAsVacant= 'Y'THEN 'YES'
      WHEN SoldAsVacant='N' THEN 'NO'
	  ELSE SoldAsVacant
	  END

-- Deleting all duplicates rows

WITH RowNumCTE AS(
SELECT *,
       ROW_NUMBER() OVER(
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SaleDate,
					LegalReference,
					SalePrice
					ORDER BY
					  UniqueID
					  )row_num

FROM [Housing Data Cleaning].DBO.Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- DELETING UNUSED COLUMNS

ALTER TABLE Housing
DROP COLUMN PropertyAddress,SaleDate, OwnerAddress,TaxDistrict



