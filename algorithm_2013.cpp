// DP-DP Console.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

struct mt_record {
	long LINE;
	long NO;
	char BUYSELL;
	int TIME;
	int TIMESEC;
	long ORDERNO; // в качестве неуникального ключа отображения
	int ACTION;
	float PRICE;
	long VOLUME;
	long TRADENO;
	float TRADEPRICE;
	long PLOTNO;
};

// мой тип; отображение с неуникальными ключами; ключ -- ORDERNO
typedef multimap<long,mt_record> mt_onday;
mt_onday CurDayMMon;
// мой тип; вектор, в котором номер элемента -- номер строки LINE в mt_record, а значение -- mt_trade
typedef vector<mt_record> mt_tnday;
mt_tnday CurDayVtn;
// мой тип; отображение с неуникальными ключами; ключ -- PLOTNO
typedef multimap<long,mt_record> mt_pnday;
mt_pnday CurDayMMpn;

int timeSec(int RawTime) {
	double T, Hours, Minutes, Seconds;

	T = RawTime/1000;

	Hours = floor(T*pow(10.0,-4));
	Minutes = floor((T - Hours*pow(10.0,4))*pow(10.0,-2));
	Seconds = floor((T - Hours*pow(10.0,4)-Minutes*pow(10.0,2)));
	
	T = Hours*3600 + Minutes*60 + Seconds;

	T = T - 37800;

	return lexical_cast<int>(T);
};

// то, что было в temp (в tmain)
void MakeDayMapAndVec(string ll1) {
	typedef boost::tokenizer<boost::char_separator<char> > tokenizer;
	
	// описываем разделители токенов и просим сохранять пустые токены (последние две запииси, когда не сделка)
	char_separator<char> sep(",", "", keep_empty_tokens);
	mt_record rec; // буфер для считывания очередной записи и разбора ее на токены
	static long CompRecLine = 0; // номер записи в файле по данной компании
	tokenizer tok(ll1,sep);
	tokenizer::iterator it = tok.begin();
	rec.LINE = CompRecLine; ++CompRecLine;
	rec.NO = lexical_cast<long>(*it);	++it;
	++it; // пропустить SECCODE и перейти к BUYSELL
	rec.BUYSELL = lexical_cast<char>(*it); ++it;
	rec.TIME = (lexical_cast<int>(*it))/1000;
	rec.TIMESEC = timeSec(lexical_cast<int>(*it)); ++it;
	long ORDERNO = lexical_cast<long>(*it); // в качестве неуникального ключа отображения
	rec.ORDERNO = lexical_cast<long>(*it); // ...и в здесь тоже
	++it;
	rec.ACTION = lexical_cast<int>(*it); ++it;
	rec.PRICE = lexical_cast<float>(*it); ++it;
	rec.VOLUME = lexical_cast<long>(*it); ++it;
	// если не сделка
	if (!(*it)[0]) {
		rec.TRADENO = -1; ++it;
		rec.TRADEPRICE = -1; ++it;
	}
	else {
		rec.TRADENO = lexical_cast<long>(*it); ++it;
		rec.TRADEPRICE = lexical_cast<float>(*it); ++it;
	}
	rec.PLOTNO = -1;

	CurDayMMon.insert(make_pair(ORDERNO,rec));

	CurDayVtn.push_back(rec);		
};


// ищем сюжеты
void Plots(void) {
	long Observations = CurDayMMon.size();
	typedef set<long> mt_seton;
	mt_seton OrderNos; // номера заявок-сделок, входящих в один сюжет
	int CurrentOrderNosAgain = 0; // менять или не менять OrderNos и CurrentPlotNo
	int NumberOfOrderNos; // количество проверяемых ORDERNO на текущей CurrentLine
	int CurrentPlotNo = -1;
	int NewTrade;
	mt_seton::iterator ONsit;

	for (long CurrentLine=0; CurrentLine < Observations; CurrentLine++) {
	// если MYORDERNO записи еще не заполнен
		if(CurDayVtn[CurrentLine].PLOTNO == -1 || CurrentOrderNosAgain) {
			// если надо сменить OrderNos и CurrentPlotNo
			if (!CurrentOrderNosAgain) {
				// искать сделки с ORDERNO(CurrentLine)
				OrderNos.erase(OrderNos.begin(),OrderNos.end());
				OrderNos.insert(CurDayVtn[CurrentLine].ORDERNO);
				// количество OrderNos сейчас 1
				NumberOfOrderNos = 1;
				CurrentPlotNo = CurrentPlotNo + 1;
			} // if (!CurrentOrderNosAgain = 0)

		// находим все записи которым нужно присвоить тот же CurrentPlotNo
			for(long i=CurrentLine; i<Observations; i++) {
				// если номер MyTradeNo еще не присвоен
				if(CurDayVtn[i].PLOTNO == -1) {
					// показатель соответствия ORDERNO записи !i искомым OrderNos (обнулен; если есть, будет исправлен на 1)
					int IfOrderNos = 0;
					// проверить, соответствует ли
					mt_seton::iterator ONsit = OrderNos.find(CurDayVtn[i].ORDERNO);
					mt_seton::iterator endit = OrderNos.end();
					if(ONsit != endit)
						IfOrderNos = 1;
					// если ORDERNO записи !i соответствует искомым OrderNos
					if(IfOrderNos) {
						// присвоить
						CurDayVtn[i].PLOTNO = CurrentPlotNo;
						NewTrade = 0;
						// если это сделка
						if(CurDayVtn[i].TRADENO != -1) {
							// если запись не первая и не последняя
							if(i>0 && i<(Observations-1)) {
								// если след. или пред. запись описывает противоположную сторону той же сделки и эта след. или пред. сделка еще не описана в MYORDERNO
								if ((CurDayVtn[i].TRADENO == CurDayVtn[i+1].TRADENO && CurDayVtn[i+1].PLOTNO == -1) ||
									(CurDayVtn[i].TRADENO == CurDayVtn[i-1].TRADENO && CurDayVtn[i-1].PLOTNO == -1)) {
									// номер парной сделки (i-1) или (i+1)
									long MatchingTrade;
									if(CurDayVtn[i].TRADENO == CurDayVtn[i-1].TRADENO)
										MatchingTrade = i-1;
									else
										MatchingTrade = i+1;
									// показатель новизны сделки в сюжете -- истина; если нет, то в цикле по !k он будет обнулен
									NewTrade = 1;
									ONsit = OrderNos.find(CurDayVtn[MatchingTrade].ORDERNO);
									if(ONsit != OrderNos.end())
										NewTrade = 0;
									// если сделка новая, то увеличить
									if(NewTrade) {
										NumberOfOrderNos = NumberOfOrderNos +1;
										// впредь присваивать этот CurentMyOrderNo зяавкам-сделкам и с этим ORDERNO тоже
										OrderNos.insert(CurDayVtn[MatchingTrade].ORDERNO);
										// присвоить
										CurDayVtn[MatchingTrade].PLOTNO = CurrentPlotNo;

										// не менять OrderNos и CurrentMyOrderNo
										CurrentOrderNosAgain = 1;
										// выйти из for !i=CurrentLine to Observations
										i = Observations;
										// начать сначала for CurrentLine = 1 to Observations
										CurrentLine = 0;
									}
								} //if ((CurDayVtn[i].TRADENO=CurDayVtn[i+1].TRADENO && CurDayVtn[i+1].PLOTNO == -1) ||
									//	(CurDayVtn[i].TRADENO=CurDayVtn[i-1].TRADENO && CurDayVtn[i-1].PLOTNO == -1))
							} // if(i>0 && i<(Observations-1))
						} // if(CurDayVtn[i].TRADENO)
					} // if(IfOrderNos)
				} // if(CurDayVtn[i].PLOTNO == -1)
			} // for(long i=CurrentLine; i<Observations; i++)
			//если !i дошла до Observations без добавок новых ORDERNO, то второй проход не нужен
			if(!NewTrade) {
				cout << "CurrentPlotNo = " << CurrentPlotNo << "\n";
				CurrentOrderNosAgain = 0;
			}

		} // if(CurDayVtn[CurrentLine]. = -1 || CurrentOrderNosAgain)
	} // for (long CurrentLine=0; CurrentLine < Observations; CurrentLine++)
};

void WriteOrderLogCompFile(ifstream &orderLogFile, ofstream &orderLogCompFile, char *date, char * compName) {
	
	string orderLogLine; // буфер для переноса 
	
	while(getline(orderLogFile, orderLogLine)) {
		// проверить не конец файла
		int oLL_f = orderLogLine.find(compName/*"GAZP"*/);
		if (oLL_f != -1) {
			MakeDayMapAndVec(orderLogLine);
		}
	}
	// чтобы не появлялся лишний сюжет с последней строкой (добавляется произвольная строка (только ORDERNO строго уникальный))
	MakeDayMapAndVec("90744,RU0009046700,B,184600000,-1,0,18.45,93,,");

	// найти и пронумеровать сюжеты
	Plots();
	// убрать произвольную строку из отображения и вектора
	mt_onday::iterator tempmmit;
	tempmmit = CurDayMMon.find(-1);
	CurDayMMon.erase(tempmmit);
	mt_tnday::iterator tempvit;
	tempvit = CurDayVtn.end(); --tempvit;
	CurDayVtn.erase(tempvit);
//	CurDayMMon.erase(CurDayMMon.end()-1);

	for(long i=0; i < CurDayVtn.size(); i++) {
		orderLogCompFile << CurDayVtn[i].NO << "," << CurDayVtn[i].BUYSELL << ","
						<< CurDayVtn[i].TIME << "," << CurDayVtn[i].TIMESEC << ","
						<< CurDayVtn[i].ORDERNO << "," << CurDayVtn[i].ACTION << ","
						<< CurDayVtn[i].PRICE << "," << CurDayVtn[i].VOLUME << ",";
		if(CurDayVtn[i].TRADENO == -1)
			orderLogCompFile << ",,";
		else
			orderLogCompFile << CurDayVtn[i].TRADENO << "," << CurDayVtn[i].TRADEPRICE << ",";
		orderLogCompFile << CurDayVtn[i].PLOTNO << "\n";
	}
}

void MakeOrderLogCompFile(char *orderLogFileName, char * orderLogCompFileName, char * compName) {
	
	string orderLogLine; // буфер для переноса 
	
	ofstream orderLogCompFile(orderLogCompFileName);
	// файл с orderLog конкретной компании
	
//	int i = 0;
//	while (orderLogFileNames[i][0]) { // пока не кончились ордерлоги (первый символ '\0')
		
		cout << orderLogFileName << "\n";
		
		ifstream orderLogFile(orderLogFileName);
		// файл откуда берутся данные по конкретной компании
		
		char date[10];
		for(int k=8; k<=15; k++) date[k-8] = orderLogFileName[k];
		date[8] = '\0'; // изъяли дату из ордерлога для вставки в файлкомп
		
		getline(orderLogFile, orderLogLine); // считали строку заголовка
		/* заоголовок для OrderLog */
		orderLogCompFile << "NO,BUYSELL,TIME,TIMESEC,ORDERNO,ACTION,PRICE,VOLUME,TRADENO,TRADEPRICE,PLOTNO\n";
		/* заоголовок для TradeLog */
		//if(i == 0) orderLogCompFile << "DATE,TRADENO,SECCODE,TIME,BUYORDERNO,SELLORDERNO,PRICE,VOLUME\n";
		// скопировали заголовок (только один раз в начале!)
		
		WriteOrderLogCompFile(orderLogFile, orderLogCompFile, date, compName);

		cout << orderLogFile << "\n";

		orderLogFile.close();
		
//		++i; // следующий ордерлог
//	} // while (orderLogFileNames[i][0])
	orderLogCompFile.close();
}

void FillInOrderLineStruct(string &buf, int &DATE) {
}

int _tmain(int argc, _TCHAR* argv[])
{
/*	char * orderLogFileNames2002[] = {"OrderLog20020812.txt", "OrderLog20020813.txt",
									"OrderLog20020814.txt", "OrderLog20020815.txt",
									"OrderLog20020816.txt",
									"OrderLog20020819.txt", "OrderLog20020820.txt",
									"OrderLog20020821.txt", "OrderLog20020822.txt",
									"OrderLog20020823.txt",
									"OrderLog20020826.txt", "OrderLog20020827.txt",
									"OrderLog20020828.txt", "OrderLog20020829.txt",
									"OrderLog20020830.txt",
									"OrderLog20020902.txt", "OrderLog20020903.txt",
									"OrderLog20020904.txt", "OrderLog20020905.txt",
									"OrderLog20020906.txt",
									"OrderLog20020909.txt", "OrderLog20020910.txt",
									"OrderLog20020911.txt", "OrderLog20020912.txt",
									"OrderLog20020913.txt",
									"OrderLog20020916.txt", "OrderLog20020917.txt",
									"OrderLog20020918.txt", "OrderLog20020919.txt",
									"OrderLog20020920.txt",
									"OrderLog20020923.txt", "OrderLog20020924.txt",
									"OrderLog20020925.txt", "OrderLog20020926.txt",
									"OrderLog20020927.txt",
									"OrderLog20020930.txt", "OrderLog20021001.txt",
									"OrderLog20021002.txt", "OrderLog20021003.txt",
									"OrderLog20021004.txt",
									"OrderLog20021007.txt", "OrderLog20021008.txt",
									"OrderLog20021009.txt", "OrderLog20021010.txt",
									"OrderLog20021011.txt",
									"OrderLog20021014.txt", "OrderLog20021015.txt",
									"OrderLog20021016.txt", "OrderLog20021017.txt",
									"OrderLog20021018.txt",
									"\0"}; */

	char * orderLogFileNames2002[] = {"OrderLog20021021.txt", "OrderLog20021022.txt",
									"OrderLog20021023.txt",	"OrderLog20021024.txt",
									"OrderLog20021025.txt",
									"OrderLog20021028.txt", "OrderLog20021029.txt",
									"OrderLog20021030.txt", "OrderLog20021031.txt",
									"\0"};

/*	char * orderLogFileNames2007[] = {"OrderLog20071001.txt", "OrderLog20071002.txt",
									"OrderLog20071003.txt", "OrderLog20071004.txt",
									"OrderLog20071005.txt",
									"OrderLog20071006.txt", "OrderLog20071007.txt",
									"OrderLog20071008.txt", "OrderLog20071009.txt",
									"OrderLog20071010.txt",
									"OrderLog20071011.txt", "OrderLog20071012.txt",
									"OrderLog20071013.txt", "OrderLog20071014.txt",
									"OrderLog20071015.txt",
									"OrderLog20071016.txt", "OrderLog20071017.txt",
									"OrderLog20071018.txt", "OrderLog20071019.txt",
									"OrderLog20071020.txt",
									"OrderLog20071021.txt", "OrderLog20071022.txt",
									"OrderLog20071023.txt", "OrderLog20071024.txt",
									"OrderLog20071025.txt",
									"OrderLog20071026.txt", "OrderLog20071027.txt",
									"OrderLog20071028.txt", "OrderLog20071029.txt",
									"OrderLog20071030.txt",
									"OrderLog20071031.txt",
									"\0"}; */

//============================== 2002 год ============================

	string OLCompFN; // имя файла, куда пойдут ордерлог за этот день (скаладывается из имен комп. и ордерлог)
	string SECCODE = "RU0009024277";
	int i = 0;
	while (orderLogFileNames2002[i][0]) { // пока не кончились ордерлоги (первый символ '\0')
	OLCompFN = SECCODE + "_" + orderLogFileNames2002[i];
		MakeOrderLogCompFile(orderLogFileNames2002[i], (char *)OLCompFN.data(), (char *)SECCODE.data());

		// очистить отображение и вектор
		CurDayMMon.erase(CurDayMMon.begin(), CurDayMMon.end());
		CurDayVtn.erase(CurDayVtn.begin(), CurDayVtn.end());

		++i; // следующий ордерлог
	} // while (orderLogFileNames[i][0])

//============================== 2007 год ============================

/*	SECCODE = "LKOH";
	i=0;
	while (orderLogFileNames2007[i][0]) { // пока не кончились ордерлоги (первый символ '\0')
	OLCompFN = SECCODE + "_" + orderLogFileNames2007[i];
		MakeOrderLogCompFile(orderLogFileNames2007[i], (char *)OLCompFN.data(), (char *)SECCODE.data());

		// очистить отображение и вектор
		CurDayMMon.erase(CurDayMMon.begin(), CurDayMMon.end());
		CurDayVtn.erase(CurDayVtn.begin(), CurDayVtn.end());

		++i; // следующий ордерлог
	} // while (orderLogFileNames[i][0])*/

	return 0;
}

