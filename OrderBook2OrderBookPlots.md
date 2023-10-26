```python
%run ./OrderBookPlots.ipynb
```

part = []

whole = ['a', 'b', 'c' ,'d']

print(len(whole))

whole_ser = pd.Series(whole)
whole_ser[~whole_ser.isin(part)].to_list()


```python
# the algorithm (CC.java) is taken from https://algs4.cs.princeton.edu/41graph/

class OrderBook2OrderBookPlots:
    def __init__(self, taq_df,
              row_id_col, # unique row id
              sec_col, # column with security code
              link_col, # orderno or some mark linking trades and quotes
              trdno_col,
              only_secs = []
             ):
        self.OrderBookPlots_df = taq_df.copy()
        self.row_id_col = row_id_col
        self.sec_col = sec_col
        self.link_col = link_col
        self.trdno_col = trdno_col
        
        self.secs = pd.unique(taq_df[sec_col])
        if len(only_secs) > 0:
            only_secs_ser = pd.Series(only_secs)
            self.wrong_secs = only_secs_ser[~only_secs_ser.isin(self.secs)].to_list()
            if len(self.wrong_secs) > 0:
                self.OrderBookPlots_df =pd.DataFrame()
                raise SystemExit(f"Wrong SECCODES: {self.wrong_secs}")
            else:
                self.secs = only_secs
        self.OrderBookPlots_df = self.OrderBookPlots_df[self.OrderBookPlots_df.SECCODE.isin(self.secs)]
        
        self.vertex_count_dic = {k:v for (k, v) in zip(self.secs, [0 for i in range(len(self.secs))])}
        self.rowid2gkey_dic = {k:v for (k, v) in zip(self.secs, [{} for i in range(len(self.secs))])}
        self.lnk2gkey_dic = {k:v for (k, v) in zip(self.secs, [{} for i in range(len(self.secs))])}
        self.trdno2gkey_dic = {k:v for (k, v) in zip(self.secs, [{} for i in range(len(self.secs))])}
        self.edge_tpls = {k:v for (k, v) in zip(self.secs, [[] for i in range(len(self.secs))])}
        
        self.rows_to_edges()
        
        self.Gs = {k:v for (k, v) in zip(self.secs, [Graph(self.edge_tpls[sec],
                                                           self.vertex_count_dic[sec]) for sec in self.secs])}
        self.OBPs = {k:v for (k, v) in zip(self.secs, [OrderBookPlots(self.Gs[sec]) for sec in self.secs])}
        
        self.to_OBPlots_df()

    def sec_rowid_lnk2edges(self, rowid, sec, lnk, trdno): 
        # give 0, 1, 2, ... vertex names to all raw ids and "links" (eg ordernos)
        if rowid not in self.rowid2gkey_dic[sec]:
            self.rowid2gkey_dic[sec][rowid] = self.vertex_count_dic[sec]
            self.vertex_count_dic[sec] += 1
        if lnk not in self.lnk2gkey_dic[sec]:
            self.lnk2gkey_dic[sec][lnk] = self.vertex_count_dic[sec]
            self.vertex_count_dic[sec] += 1
        if trdno not in self.trdno2gkey_dic[sec]:
            self.trdno2gkey_dic[sec][trdno] = self.vertex_count_dic[sec]
            self.vertex_count_dic[sec] += 1
        self.edge_tpls[sec].append((self.rowid2gkey_dic[sec][rowid], 
                               self.lnk2gkey_dic[sec][lnk]))
        if pd.notna(trdno):
            self.edge_tpls[sec].append((self.rowid2gkey_dic[sec][rowid], 
                               self.trdno2gkey_dic[sec][trdno]))

    def rows_to_edges(self):
        [self.sec_rowid_lnk2edges(rowid, sec, lnk, trdno) 
         for rowid, sec, lnk, trdno in zip(self.OrderBookPlots_df[self.row_id_col],
                                    self.OrderBookPlots_df[self.sec_col],
                                    self.OrderBookPlots_df[self.link_col],
                                    self.OrderBookPlots_df[self.trdno_col])]
        
    def to_OBPlots_df(self):
        self.OrderBookPlots_df['OBPLOTNO'] = [self.OBPs[sec].OBPlotnos[self.rowid2gkey_dic[sec][rowid]] 
                                    for (sec, rowid) in zip(self.OrderBookPlots_df['SECCODE'], 
                                                            self.OrderBookPlots_df['NO'])]
```


```python
# OrderLog = 'OrderLog20020812'
# #OrderLog = 'OrderLog20071001'
# OrderLog_df = pd.read_csv('../resources/' + OrderLog + '.txt')

# OrderLog_df = OrderLog_df.astype({"NO":"int",
#                                   "SECCODE":"string",
#                                   "BUYSELL":"string",
#                                   "TIME":"string",
#                                   "ORDERNO":"int",
#                                   "ACTION":"int",
#                                   "PRICE":"float",
#                                   "VOLUME":"int",
#                                   "TRADENO":pd.Int64Dtype(),
#                                   "TRADEPRICE":"float"
#                                  })
# OrderLog_df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>NO</th>
      <th>SECCODE</th>
      <th>BUYSELL</th>
      <th>TIME</th>
      <th>ORDERNO</th>
      <th>ACTION</th>
      <th>PRICE</th>
      <th>VOLUME</th>
      <th>TRADENO</th>
      <th>TRADEPRICE</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>RU14VOST1005</td>
      <td>S</td>
      <td>103000000</td>
      <td>1</td>
      <td>1</td>
      <td>2.380</td>
      <td>4500</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>RU0009071187</td>
      <td>S</td>
      <td>103000000</td>
      <td>2</td>
      <td>1</td>
      <td>990.000</td>
      <td>300</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>RU14VOST1005</td>
      <td>S</td>
      <td>103000000</td>
      <td>3</td>
      <td>1</td>
      <td>2.420</td>
      <td>21600</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>RU0009100762</td>
      <td>B</td>
      <td>103000000</td>
      <td>4</td>
      <td>1</td>
      <td>0.133</td>
      <td>100000</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>RU0009054449</td>
      <td>S</td>
      <td>103000000</td>
      <td>5</td>
      <td>1</td>
      <td>332.000</td>
      <td>500</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>90739</th>
      <td>90740</td>
      <td>RU14TATN3006</td>
      <td>B</td>
      <td>184557000</td>
      <td>38574</td>
      <td>1</td>
      <td>18.770</td>
      <td>50000</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>90740</th>
      <td>90741</td>
      <td>RU14VOST1005</td>
      <td>S</td>
      <td>184558000</td>
      <td>38559</td>
      <td>0</td>
      <td>1.990</td>
      <td>49800</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>90741</th>
      <td>90742</td>
      <td>RU0009046700</td>
      <td>S</td>
      <td>184559000</td>
      <td>38575</td>
      <td>1</td>
      <td>18.450</td>
      <td>100000</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>90742</th>
      <td>90743</td>
      <td>RU0009071187</td>
      <td>B</td>
      <td>184559000</td>
      <td>38550</td>
      <td>0</td>
      <td>725.840</td>
      <td>1</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>90743</th>
      <td>90744</td>
      <td>RU0009046700</td>
      <td>B</td>
      <td>184600000</td>
      <td>38534</td>
      <td>0</td>
      <td>18.450</td>
      <td>93</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
<p>90744 rows × 10 columns</p>
</div>




```python
# OrderBookPlots_df = OrderBook2OrderBookPlots(OrderLog_df, 'NO', 'SECCODE', 'ORDERNO', 'TRADENO', []).OrderBookPlots_df
# OrderBookPlots_df.to_csv('./' + OrderLog + '.csv')
# OrderBookPlots_df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>NO</th>
      <th>SECCODE</th>
      <th>BUYSELL</th>
      <th>TIME</th>
      <th>ORDERNO</th>
      <th>ACTION</th>
      <th>PRICE</th>
      <th>VOLUME</th>
      <th>TRADENO</th>
      <th>TRADEPRICE</th>
      <th>OBPLOTNO</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1</td>
      <td>RU14VOST1005</td>
      <td>S</td>
      <td>103000000</td>
      <td>1</td>
      <td>1</td>
      <td>2.380</td>
      <td>4500</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>2</td>
      <td>RU0009071187</td>
      <td>S</td>
      <td>103000000</td>
      <td>2</td>
      <td>1</td>
      <td>990.000</td>
      <td>300</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>3</td>
      <td>RU14VOST1005</td>
      <td>S</td>
      <td>103000000</td>
      <td>3</td>
      <td>1</td>
      <td>2.420</td>
      <td>21600</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>2</td>
    </tr>
    <tr>
      <th>3</th>
      <td>4</td>
      <td>RU0009100762</td>
      <td>B</td>
      <td>103000000</td>
      <td>4</td>
      <td>1</td>
      <td>0.133</td>
      <td>100000</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>5</td>
      <td>RU0009054449</td>
      <td>S</td>
      <td>103000000</td>
      <td>5</td>
      <td>1</td>
      <td>332.000</td>
      <td>500</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>0</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>90739</th>
      <td>90740</td>
      <td>RU14TATN3006</td>
      <td>B</td>
      <td>184557000</td>
      <td>38574</td>
      <td>1</td>
      <td>18.770</td>
      <td>50000</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>209</td>
    </tr>
    <tr>
      <th>90740</th>
      <td>90741</td>
      <td>RU14VOST1005</td>
      <td>S</td>
      <td>184558000</td>
      <td>38559</td>
      <td>0</td>
      <td>1.990</td>
      <td>49800</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>161</td>
    </tr>
    <tr>
      <th>90741</th>
      <td>90742</td>
      <td>RU0009046700</td>
      <td>S</td>
      <td>184559000</td>
      <td>38575</td>
      <td>1</td>
      <td>18.450</td>
      <td>100000</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>357</td>
    </tr>
    <tr>
      <th>90742</th>
      <td>90743</td>
      <td>RU0009071187</td>
      <td>B</td>
      <td>184559000</td>
      <td>38550</td>
      <td>0</td>
      <td>725.840</td>
      <td>1</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>230</td>
    </tr>
    <tr>
      <th>90743</th>
      <td>90744</td>
      <td>RU0009046700</td>
      <td>B</td>
      <td>184600000</td>
      <td>38534</td>
      <td>0</td>
      <td>18.450</td>
      <td>93</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>355</td>
    </tr>
  </tbody>
</table>
<p>90744 rows × 11 columns</p>
</div>




```python
# plot30_df = OrderBookPlots_df[(OrderBookPlots_df.SECCODE == 'RU0009024277') & 
#                               (OrderBookPlots_df.OBPLOTNO == 30)]
# plot30_df.to_csv('./' + 'plot30' + '.csv')
# plot30_df
```




<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }
</style>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>NO</th>
      <th>SECCODE</th>
      <th>BUYSELL</th>
      <th>TIME</th>
      <th>ORDERNO</th>
      <th>ACTION</th>
      <th>PRICE</th>
      <th>VOLUME</th>
      <th>TRADENO</th>
      <th>TRADEPRICE</th>
      <th>OBPLOTNO</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>480</th>
      <td>481</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>103000000</td>
      <td>481</td>
      <td>1</td>
      <td>480.00</td>
      <td>20</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
    <tr>
      <th>1122</th>
      <td>1123</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>103000000</td>
      <td>1123</td>
      <td>1</td>
      <td>480.02</td>
      <td>200</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
    <tr>
      <th>2155</th>
      <td>2156</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>103135000</td>
      <td>1866</td>
      <td>1</td>
      <td>480.01</td>
      <td>500</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
    <tr>
      <th>3866</th>
      <td>3867</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>103701000</td>
      <td>2834</td>
      <td>1</td>
      <td>480.01</td>
      <td>50</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
    <tr>
      <th>3880</th>
      <td>3881</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>103705000</td>
      <td>2847</td>
      <td>1</td>
      <td>480.01</td>
      <td>1</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>13656</th>
      <td>13657</td>
      <td>RU0009024277</td>
      <td>S</td>
      <td>111707000</td>
      <td>7550</td>
      <td>2</td>
      <td>480.00</td>
      <td>138</td>
      <td>29846687</td>
      <td>480.0</td>
      <td>30</td>
    </tr>
    <tr>
      <th>13799</th>
      <td>13800</td>
      <td>RU0009024277</td>
      <td>S</td>
      <td>111737000</td>
      <td>7624</td>
      <td>1</td>
      <td>480.00</td>
      <td>100</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
    <tr>
      <th>13801</th>
      <td>13802</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>111737000</td>
      <td>2937</td>
      <td>2</td>
      <td>480.00</td>
      <td>100</td>
      <td>29846711</td>
      <td>480.0</td>
      <td>30</td>
    </tr>
    <tr>
      <th>13802</th>
      <td>13803</td>
      <td>RU0009024277</td>
      <td>S</td>
      <td>111737000</td>
      <td>7624</td>
      <td>2</td>
      <td>480.00</td>
      <td>100</td>
      <td>29846711</td>
      <td>480.0</td>
      <td>30</td>
    </tr>
    <tr>
      <th>17253</th>
      <td>17254</td>
      <td>RU0009024277</td>
      <td>B</td>
      <td>113727000</td>
      <td>2937</td>
      <td>0</td>
      <td>480.00</td>
      <td>1987</td>
      <td>&lt;NA&gt;</td>
      <td>NaN</td>
      <td>30</td>
    </tr>
  </tbody>
</table>
<p>107 rows × 11 columns</p>
</div>




```python
# OrderBookPlots_df.to_csv('./resources/OrderLog20020812_OBP.csv')
```
