/*
Topic: Data Cleaning in SQL Queries
*/

Select *
From NashvilleHousingData

------------------------------------------------------------------------------------------------------------------------------

--Standardized Sales Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate) as DateColumn
From NashvilleHousingData

Update NashvilleHousingData
Set SaleDate = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------------
--Trying this since the SalesDate Format did not work

Alter Table NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
Set SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

Select PropertyAddress
From NashvilleHousingData
Where PropertyAddress is null

Select*
From NashvilleHousingData
--Where PropertyAddress is null
Order By ParcelID


Select N.ParcelID,N.PropertyAddress, V.ParcelID, V.PropertyAddress, ISNULL(N.PropertyAddress,V.PropertyAddress)
From NashvilleHousingData N
Join NashvilleHousingData V
On N.ParcelID = V.ParcelID
And N.[UniqueID ] <> V.[UniqueID ]
Where N.PropertyAddress is null


Update N
Set PropertyAddress = ISNULL(N.PropertyAddress,V.PropertyAddress)
From NashvilleHousingData N
Join NashvilleHousingData V
On N.ParcelID = V.ParcelID
And N.[UniqueID ] <> V.[UniqueID ]
Where N.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------
--Breaking out Addressess into individual Columns (Adress,City,State)

Select PropertyAddress
From NashvilleHousingData

--SUBSTRING STARTS TO WORK OR COUNT FROM THE FRONT

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvilleHousingData


Alter Table NashvilleHousingData
Add PropertySplitAddress Nvarchar (255);

Update NashvilleHousingData
Set PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


Alter Table NashvilleHousingData
Add PropertySplitCity Nvarchar (255);

Update NashvilleHousingData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select *
From NashvilleHousingData


Select OwnerAddress
From NashvilleHousingData

--PARSENAME WORKS WITH EVERTHING COUNTING FROM THE BACK
Select 
PARSENAME(Replace(OwnerAddress,',', '.'),3),
PARSENAME(Replace(OwnerAddress,',', '.'),2),
PARSENAME(Replace(OwnerAddress,',', '.'),1)
From NashvilleHousingData


Alter Table NashvilleHousingData
Add OwnerSplitAddress Nvarchar (255);

Update NashvilleHousingData
Set OwnerSplitAddress  = PARSENAME(Replace(OwnerAddress,',', '.'),3)


Alter Table NashvilleHousingData
Add OwnerSplitCity Nvarchar (255);

Update NashvilleHousingData
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'),2)


Alter Table NashvilleHousingData
Add OwnerSplitState Nvarchar (255);

Update NashvilleHousingData
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'),1)

Select *
From NashvilleHousingData

----------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "SoldAsVacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousingData
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
Case When SoldAsVacant = 'N' Then 'No'
     When SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
	 End
From NashvilleHousingData


Update NashvilleHousingData
Set SoldAsVacant = Case When SoldAsVacant = 'N' Then 'No'
     When SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
	 End
From NashvilleHousingData


----------------------------------------------------------------------------------------------------------------
--Remove Duplicates

With RowNumCTE As (
Select *,
ROW_NUMBER() Over (
Partition By ParcelID,
PropertyAddress,SaleDate,SalePrice,LegalReference
Order By UniqueID) row_num

From NashvilleHousingData
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress

--THIS IS TO DELETE DUPLICATE

With RowNumCTE As (
Select *,
ROW_NUMBER() Over (
Partition By ParcelID,
PropertyAddress,SaleDate,SalePrice,LegalReference
Order By UniqueID) row_num

From NashvilleHousingData
--Order By ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


-------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select *
From NashvilleHousingData

Alter Table NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousingData
Drop Column SaleDate