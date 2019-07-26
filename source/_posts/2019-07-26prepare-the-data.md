---
title: 机器学习(1). 数据预处理
date: 2019-07-26 08:21:48
tags: 
categories: ML
---

在训练模型之前，需要对数据进行预处理，主要包括以下几步：划分数据集、数据清理、处理非数值类型等。

### 划分数据集

划分数据集主要是把数据划分为训练集以及测试集，训练集是用来训练/优化模型的，在这个过程中一定不要涉及到测试集，只有在最后确定了模型才能使用测试集对模型进行检验，确定该模型对于新数据的适用情况。常见的情况是把2/3 ~ 4/5的样本用作训练，剩余样本用于测试。

#### 随机划分

随机划分即根据分配比，随机挑选样本到训练集和测试集中。这样很简单，但是没有考虑数据分布的问题，举个例子，在进行调查问卷时，可能会按照性别比来分发问卷来取得更具有代表性的结论。

``` python
import numpy as np

def split_train_test(data, test_ratio):
    """
    :data: pandas.DataFrame
    :test_ratio: float
    """
    # 将[0, 1, ..., len(data)-1]索引随机打乱
    shuffled_indices = np.random.permutation(len(data))
    test_data_size = int(len(data) * test_ratio)
    test_indices = shuffled_indices[:test_data_size]
    train_indices = shuffled_indices[test_data_size:]
    # iloc根据传递的索引列表取得对应的数据
    return data.iloc[train_indices], data.iloc[test_indices]
```

sklearn中也提供随机划分的方法:

``` python
from sklearn.model_selection import train_test_split
train_set, test_set = train_test_split(housing_data, test_size=0.2, random_state=42)
```

#### 分层划分

依据分层抽样法的思想，按照数据中某个比较重要属性的比例，分别抽取同样的比例的样本到训练集和测试集中。属性的重要程度可以通过各个属性和标签之间的相关性进行简单估计：

``` python
corr_matrix = housing_data.corr()
corr_matrix['median_house_value'].sort_values(ascending=False)
```

结果如下:

    median_house_value    1.000000
    median_income         0.688075
    total_rooms           0.134153
    housing_median_age    0.105623
    households            0.065843
    total_bedrooms        0.049686
    population           -0.024650
    longitude            -0.045967
    latitude             -0.144160
    Name: median_house_value, dtype: float64

可以看到收入是和房价最相关的，进一步查看收入数据：

``` python
%matplotlib inline
import matplotlib.pyplot as plt
housing_data['median_income'].hist(bins=50, figsize=(20, 15))
plt.show()
```

![median income](https://image.zero22.top/ml/median_income.png)

但是收入的范围还是比较广的，在分层时最好不要有过多的层，而且每一层要有充足的样本，因此对收入进行二次处理，

``` python
# ceil 向上取整
housing_data['income_cat'] = np.ceil(housing_data['median_income'] / 1.5)
# 收入小于5的不作处理，大于等于5的都置为5
housing_data['income_cat'].where(housing_data['income_cat'] < 5, 5.0, inplace=True)
```

![income cat](https://image.zero22.top/ml/income_cat.png)

如此一来就有了分层的依据，进行分层划分：

``` python
from sklearn.model_selection import StratifiedShuffleSplit

split = StratifiedShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
for train_index, test_index in split.split(housing_data, housing_data['income_cat']):
    strat_train_set = housing_data.loc[train_index]
    strat_test_set = housing_data.loc[test_index]
```

查看各个数据集的收入比例:

``` python
housing_data['income_cat'].value_counts() / len(housing_data)
3.0    0.350581
2.0    0.318847
4.0    0.176308
5.0    0.114438
1.0    0.039826
Name: income_cat, dtype: float64

strat_train_set['income_cat'].value_counts() / len(strat_train_set)
3.0    0.350594
2.0    0.318859
4.0    0.176296
5.0    0.114402
1.0    0.039850
Name: income_cat, dtype: float64

strat_test_set['income_cat'].value_counts() / len(strat_test_set)
3.0    0.350533
2.0    0.318798
4.0    0.176357
5.0    0.114583
1.0    0.039729
Name: income_cat, dtype: float64
```

### 数据处理

数据处理主要是对数据进行二次处理，使其更有利于各种机器算法的训练。

#### 数据清理

在有特征丢失的情况下，大多数机器学习算法无法工作，因此需要对这些数据进行处理。有三种方法，删除含有空值的样本、删除含有空值的属性、填充空值。

``` python
# 前两种方式
op1 = op1.dropna(subset=['total_bedrooms'])
op2 = op2.drop('total_bedrooms', axis=1)
```

第三种方式一般在空值处填充该属性的均值，可以使用`SimpleImputer`来填充数值型的均值:

``` python
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(strategy='median')
# 去掉非数值属性
housing_num = housing.drop('ocean_proximity', axis=1)
imputer.fit(housing_num)
# imputer.statistics_ = housing_num.median().values
X = imputer.transform(housing_num)
housing_tr = pd.DataFrame(X, columns=housing_num.columns)
```

#### 处理非数值

对于文本类型的属性，一般将其转化为数值:

``` python
from sklearn.preprocessing import LabelEncoder
encoder = LabelEncoder()
housing_cat = housing['ocean_proximity']
housing_cat_encoded = encoder.fit_transform(housing_cat)
# print(housing_cat_encoded)
# array([0, 0, 4, ..., 1, 0, 3])   <class 'numpy.ndarray'>
```

这种方法简单的将文本属性值用数字代替，比如`<1H OCEAN`标识为`0`，`INLAND`标识为`1`等，但是这样转化会引入额外的信息，比如相近的属性值具有更强的相似性，而且也会影响特征之间的距离。因此又有了独热码的处理方式：

``` python
from sklearn.preprocessing import OneHotEncoder
encoder = OneHotEncoder()
housing_cat_1hot = encoder.fit_transform(housing_cat_encoded.reshape(-1,1))
# print(housing_cat_1hot)  
# (0, 0)  1.0
# (1, 0)  1.0
# (2, 4)  1.0
# (3, 1)  1.0
# (4, 0)  1.0
# (5, 1)  1.0
# (6, 0)  1.0
# ...
# <16512x5 sparse matrix of type '<class 'numpy.float64'>'
#   with 16512 stored elements in Compressed Sparse Row format>
```

由于该属性有5个值，因此独热码有5位，对于一个具体的特征值来说，其独热码中该特征值位置为1，其余为0，上述输出的`(2, 4)`表示第2个样本的该特征值为`1`的位置在4，这样用`1`的位置来表示独热码能够节省大量的空间。

除了上述的将文本值转化为标签，再转化为独热码外，还可以直接使用`LabelBinarizer`将文本值转化为独热码:

``` python
from sklearn.preprocessing import LabelBinarizer
encoder = LabelBinarizer(sparse_output=True)
housing_cat_1hot = encoder.fit_transform(housing_cat)
# housing_cat_1hot
# <16512x5 sparse matrix of type '<class 'numpy.int32'>'
#   with 16512 stored elements in Compressed Sparse Row format>
```

### 补充

上述的整个流程都可以使用`pipeline`一次完成。
