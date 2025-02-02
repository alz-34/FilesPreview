﻿#Область РаботаСФормами

Процедура ПриСозданииФормы(Форма, Отказ) Экспорт
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьПредварительныйПросмотрФайлов") Тогда
		Возврат;
	КонецЕсли;
	
	Если Форма.ИмяФормы = "Обработка.Демо_ФормаПросмотра.Форма.Форма" Тогда		
		Обработки.Демо_ФормаПросмотра.НастроитьФормуДляПросмотраФайлов(Форма);					
	КонецЕсли;                                                  	

КонецПроцедуры

Процедура УстановитьОбщиеЗначенияРеквизитовФормы(Форма) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Форма.НастройкиПодключенияСервисаПросмотра = Константы.ТекущаяНастройкаПодключенияСервисаПросмотра.Получить();
	УстановитьПривилегированныйРежим(Ложь);

КонецПроцедуры

Процедура ДобавитьОбщиеРеквизитыФормы(Форма) Экспорт
	
	Реквизит_ВебПредставление = Новый РеквизитФормы(
		"ВебПредставление",
		Новый ОписаниеТипов("Строка"));	
		
	Реквизит_НастройкиПодключенияСервисаПросмотра = Новый РеквизитФормы(
		"НастройкиПодключенияСервисаПросмотра",
		Новый ОписаниеТипов("СправочникСсылка.СервисыПредварительногоПросмотра"));
				
	ДобавляемыеРеквизиты = Новый Массив;
	ДобавляемыеРеквизиты.Добавить(Реквизит_ВебПредставление);
	ДобавляемыеРеквизиты.Добавить(Реквизит_НастройкиПодключенияСервисаПросмотра);	
	
	Форма.ИзменитьРеквизиты(ДобавляемыеРеквизиты);		

КонецПроцедуры

Процедура ВывестиВебПредставлениеВОкно(Форма, ИмяРеквизитаФормы, ОписаниеФайла) Экспорт
	
	Форма[ИмяРеквизитаФормы] = ПредставлениеСервисНедоступен();	
	
	Если СервисДоступен() Тогда
		ЗначениеURL = ПолучитьURLДляВывода("previewFile", ОписаниеФайла);
		Форма[ИмяРеквизитаФормы] = ЗначениеURL;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область APIСервиса

Функция ВыполнитьМетодСервиса(ИмяМетода, Параметры = Неопределено, НастройкиПодключения = Неопределено) Экспорт
	
	Если НастройкиПодключения = Неопределено Тогда
		НастройкиПодключения = Константы.ТекущаяНастройкаПодключенияСервисаПросмотра.Получить();
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(НастройкиПодключения) Тогда
		ВызватьИсключение "Не выбраны настройки подключения к сервису просмотра";
	КонецЕсли;   	
	
	Таймаут = 0;
	Если ИмяМетода = "test" Тогда		
		Таймаут = 1;	
	КонецЕсли;
	
	Соединение = ПолучитьСоединение(НастройкиПодключения, Таймаут);
	
	ТелоЗапроса = Неопределено;
	
	HTTPМетод = "GET";
	
	Если ИмяМетода = "test"  Тогда		
		ТекстЗапроса = ИмяМетода;				
	ИначеЕсли ИмяМетода = "allowedExt"  Тогда
		ТекстЗапроса = ИмяМетода;			
	ИначеЕсли ИмяМетода = "allowedExtForExt"  Тогда
		ТекстЗапроса = СтрШаблон("allowedExt/%1", Параметры.Расширение);
	ИначеЕсли ИмяМетода = "previewFile"  Тогда		
		ШаблонURL = ШаблонURL_previewFile();		
		ТекстЗапроса = СтрШаблон(ШаблонURL, Параметры.Расширение, Параметры.Имя);		
	ИначеЕсли ИмяМетода = "uploadFile"  Тогда		
		ТекстЗапроса = СтрШаблон("upload/%1/%2", НРег(Параметры.Расширение), НРег(Параметры.НовыйРасширение));				
		ТелоЗапроса  = Параметры.ДвоичныеДанные;
		HTTPМетод = "POST";
	ИначеЕсли ИмяМетода = "deleteFile"  Тогда		
		ТекстЗапроса = СтрШаблон("delete/%1/%2", НРег(Параметры.Расширение), НРег(Параметры.ИмяВСервисе));						
	КонецЕсли;
	
	Возврат ВыполнитьЗапрос(Соединение, HTTPМетод, ТекстЗапроса, ТелоЗапроса);
		      
КонецФункции

Функция СервисДоступен() Экспорт

	Результат = ВыполнитьМетодСервиса("test");	
	Возврат НЕ Результат.Ошибка;

КонецФункции // СервисДоступен()

Функция ПолучитьURLДляВывода(ИмяМетода, ФайлСсылка, НастройкиПодключения = Неопределено)
	
	Если НастройкиПодключения = Неопределено Тогда
		НастройкиПодключения = Константы.ТекущаяНастройкаПодключенияСервисаПросмотра.Получить();
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(НастройкиПодключения) Тогда
		ВызватьИсключение "Не выбраны настройки подключения к сервису просмотра";
	КонецЕсли;  
	
	Если ИмяМетода = "previewFile"  Тогда		
		ШаблонURL = ШаблонURL_previewFile();		
		URL_КонечнаяТочка = СтрШаблон(ШаблонURL, ФайлСсылка.Расширение, ФайлСсылка.Имя);		
	КонецЕсли;
	
	ЗначениеПорта = ?(Не ЗначениеЗаполнено(НастройкиПодключения.Порт), 80, НастройкиПодключения.Порт);
	ЗначениеПорта = Формат(ЗначениеПорта, "ЧГ=0");
	
	Результат = СтрШаблон("http://%1:%2/%3", 
		НастройкиПодключения.Сервер, 
		ЗначениеПорта, 
		URL_КонечнаяТочка);		
	
	Возврат Результат;
		      
КонецФункции

Функция ПредставлениеСервисНедоступен()
	                      		
	ВебПредставление = "<HTML>
						|<HEAD>
						|</HEAD>
						|<BODY>
						|    <h1>%1</h1>
						|</BODY>
						|</HTML>";
	
	Возврат СтрШаблон(ВебПредставление, ТекстСервисНедоступен());

КонецФункции // ПредставлениеСервисНедоступен()

Функция ПолучитьСоединение(НастройкиПодключения, Таймаут = 0)
		
	Возврат Новый HTTPСоединение(НастройкиПодключения.Сервер,
		?(ЗначениеЗаполнено(НастройкиПодключения.Порт), НастройкиПодключения.Порт, 80),
		НастройкиПодключения.Пользователь,
		НастройкиПодключения.Пароль,
		Неопределено,
		Таймаут); 
	
КонецФункции // ПолучитьСоединение()
	
Функция ВыполнитьЗапрос(Соединение, HTTPМетод, ТекстЗапроса, ТелоЗапроса = Неопределено, РасширенноеОписаниеОшибки = Истина, КодУспеха = 200)

	HTTPЗапрос = Новый HTTPЗапрос(ТекстЗапроса);
	
	Если ТелоЗапроса <> Неопределено Тогда
		HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/octet-stream");
	КонецЕсли;	
	
	Если ТелоЗапроса <> Неопределено Тогда
		HTTPЗапрос.УстановитьТелоИзДвоичныхДанных(ТелоЗапроса);
	КонецЕсли;
	
	Результат = Новый Структура;
	
	МассивКодовСОшибками = Новый Массив;
	МассивКодовСОшибками.Добавить(500);	
	МассивКодовСОшибками.Добавить(404);
	МассивКодовСОшибками.Добавить(400);
	
	Попытка
		Ответ = Соединение.ВызватьHTTPМетод(HTTPМетод, HTTPЗапрос);
		Если МассивКодовСОшибками.Найти(Ответ.КодСостояния) <> Неопределено Тогда
			Результат.Вставить("Ошибка", Истина);
			Результат.Вставить("ОписаниеОшибки", Ответ.ПолучитьТелоКакСтроку());
		Иначе
			Результат.Вставить("Ошибка", Ложь);
			Результат.Вставить("КодСостояния", Ответ.КодСостояния);
			Результат.Вставить("Ответ", Ответ.ПолучитьТелоКакСтроку());  		 		
		КонецЕсли;
	Исключение
		Результат.Вставить("Ошибка", Истина);
		Результат.Вставить("ОписаниеОшибки", ОписаниеОшибки());
	КонецПопытки;
	
    Возврат Результат;	  	

КонецФункции // ВыполнитьЗапрос()

Функция ШаблонURL_previewFile()
	
	Возврат "preview/%1/%2";	

КонецФункции // ШаблонURL()

#КонецОбласти

#Область РаботаСОчередьюФайлов

Процедура ОбработатьОчередьОтправкиФайлов() Экспорт
	
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьПредварительныйПросмотрФайлов") Тогда
		Возврат;
	КонецЕсли; 
	
	ЗаписьЖурналаРегистрации(
		"ОтправкаФайловВСервисПредварительногоПросмотра",
		УровеньЖурналаРегистрации.Информация, 
		,
		,
		НСтр("ru = 'Начато регламентное задание по отправке файлов в сервис'"));

		
	НастройкиПодключения = Константы.ТекущаяНастройкаПодключенияСервисаПросмотра.Получить();
	
	Попытка
		
		Если Не СервисДоступен() Тогда
			ВызватьИсключение ТекстСервисНедоступен();
		КонецЕсли;		
		
	Исключение
		
		ТекстОшибки = ОписаниеОшибки();
		
		ЗаписатьСообщениеОбОшибкеВЖР("", ТекстОшибки); 
		
		ЗаписьЖурналаРегистрации(
			"ОтправкаФайловВСервисПредварительногоПросмотра",
			УровеньЖурналаРегистрации.Информация,
			,
			,
			НСтр("ru = 'Завершено регламентное задание по отправке файлов в сервис'"));
			
		Возврат;
		
	КонецПопытки;  	
		
	МаксимальноеЧислоПопытокОбработки = Константы.МаксимальноеЧислоПопытокОбработкиЗаписиВОчереди.Получить();
	Если Не ЗначениеЗаполнено(МаксимальноеЧислоПопытокОбработки) Тогда
		МаксимальноеЧислоПопытокОбработки = 999;
	КонецЕсли;       	
		
	Пока Истина Цикл
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("МаксимальноеЧислоПопыток", МаксимальноеЧислоПопытокОбработки);
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Очередь.id КАК id,
		|	Очередь.Файл КАК Файл,
		|	Очередь.ДатаСоздания КАК ДатаСоздания,
		|	Очередь.Обработано КАК Обработано,
		|	Очередь.ДатаОбработки КАК ДатаОбработки,
		|	Очередь.ЧислоПопыток КАК ЧислоПопыток,
		|	ИменаФайловВСервисеПросмотра.Имя КАК ИмяВСервисе,
		|	ИменаФайловВСервисеПросмотра.Расширение КАК Расширение,
		|	НастройкиКонвертацииФайловВСервисе.Получатель КАК НовыйРасширение
		|ИЗ
		|	РегистрСведений.ОчередьОтправкиФайловДляПредварительногоПросмотра КАК Очередь
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ИменаФайловВСервисеПросмотра КАК ИменаФайловВСервисеПросмотра
		|		ПО Очередь.Файл = ИменаФайловВСервисеПросмотра.Файл
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиКонвертацииФайловВСервисе КАК НастройкиКонвертацииФайловВСервисе
		|		ПО Очередь.Файл.Расширение = НастройкиКонвертацииФайловВСервисе.Источник
		|ГДЕ
		|	НЕ Очередь.Обработано
		|	И Очередь.ЧислоПопыток < &МаксимальноеЧислоПопыток";
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Если РезультатЗапроса.Пустой() Тогда
			Прервать;
		КонецЕсли;		
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			
			ЧислоПопыток = Выборка.ЧислоПопыток + 1;
			                      		
			Попытка
				
				Если ЗначениеЗаполнено(Выборка.ИмяВСервисе) Тогда
					
					ОписаниеФайла = Новый Структура("ИмяВСервисе, Расширение");
					ЗаполнитьЗначенияСвойств(ОписаниеФайла, Выборка);
					РезультатЗапроса = ВыполнитьМетодСервиса("deleteFile", ОписаниеФайла, НастройкиПодключения);	
					
					Если РезультатЗапроса.Ошибка Тогда
						ВызватьИсключение РезультатЗапроса.ОписаниеОшибки;
					КонецЕсли;
					
				КонецЕсли;
				
				ОписаниеФайла = Справочники.Демо_Файлы.ПолучитьДанныеФайла(Выборка.Файл);			
				ОписаниеФайла.Вставить("НовыйРасширение", ?(ЗначениеЗаполнено(Выборка.НовыйРасширение), Выборка.НовыйРасширение, ОписаниеФайла.Расширение));
				
				РезультатЗапроса = ВыполнитьМетодСервиса("uploadFile", ОписаниеФайла, НастройкиПодключения);
				
				Если РезультатЗапроса.Ошибка Тогда
					ВызватьИсключение РезультатЗапроса.ОписаниеОшибки;
				КонецЕсли;
				
				ЧастиФайла = СтрРазделить(РезультатЗапроса.Ответ, ".");
				
				НачатьТранзакцию();	
				
				РегистрыСведений.ИменаФайловВСервисеПросмотра.ЗаписатьДанные(Выборка.Файл, ЧастиФайла[0], ЧастиФайла[1]);				
				ОбновитьЗаписьФайлаВОчереди(Выборка.id, Истина);										
				
				ЗафиксироватьТранзакцию();				
				
			Исключение 	
				
				Если ТранзакцияАктивна() Тогда
					ОтменитьТранзакцию();	
				КонецЕсли;
				
				ТекстОшибки = ОписаниеОшибки();
				
				ЗаписатьСообщениеОбОшибкеВЖР(Выборка.id, ТекстОшибки); 
				
				Попытка 						
					ОбновитьЗаписьФайлаВОчереди(Выборка.id,, ЧислоПопыток, ТекстОшибки);  					
				Исключение 					
					ЗаписатьСообщениеОбОшибкеВЖР(Выборка.id, ТекстОшибки);						
				КонецПопытки;	
				
			КонецПопытки;		
			
		КонецЦикла;			
		
	КонецЦикла;		
	
	ЗаписьЖурналаРегистрации(
		"ОтправкаФайловВСервисПредварительногоПросмотра",
		УровеньЖурналаРегистрации.Информация,
		,
		,
		НСтр("ru = 'Завершено регламентное задание по отправке файлов в сервис'"));
	    
КонецПроцедуры

Процедура ЗаписатьСообщениеОбОшибкеВЖР(id, ТекстОшибки)
	
	Перем СообщениеОбОшибке;
	
	СообщениеОбОшибке = СтрШаблон(
		"%1.
		|id: %2",
		ТекстОшибки, Строка(id));					
	
	ЗаписьЖурналаРегистрации("ОтправкаФайловВСервисПредварительногоПросмотра", 
		УровеньЖурналаРегистрации.Ошибка, 
		Метаданные.РегистрыСведений.ОчередьОтправкиФайловДляПредварительногоПросмотра, 
		, 
		СообщениеОбОшибке);

КонецПроцедуры

Процедура ДобавитьЗаписьФайлаВОчередь(СсылкаНаФайл)
	
	Набор = РегистрыСведений.ОчередьОтправкиФайловДляПредварительногоПросмотра.СоздатьНаборЗаписей();
	нЗапись = Набор.Добавить();
	нЗапись.id = Строка(Новый УникальныйИдентификатор);
	нЗапись.ДатаСоздания = ТекущаяДата();
	нЗапись.Файл = СсылкаНаФайл;
	
	Набор.Записать(Ложь);

КонецПроцедуры

Процедура ОбновитьЗаписьФайлаВОчереди(id, Обработано = Неопределено, ЧислоПопыток = Неопределено, ОписаниеОшибки = Неопределено)

	Если НЕ ЗначениеЗаполнено(Обработано) И НЕ ЗначениеЗаполнено(ЧислоПопыток) Тогда
		Возврат;
	КонецЕсли;
	
	НаборЗаписей = РегистрыСведений.ОчередьОтправкиФайловДляПредварительногоПросмотра.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.id.Установить(id);		
	НаборЗаписей.Прочитать();
	
	Если НаборЗаписей.Количество()>0 Тогда
		
		ТекущаяЗапись = НаборЗаписей[0];
		
		Если ЗначениеЗаполнено(Обработано) Тогда
			ТекущаяЗапись.Обработано = Обработано;
			Если Обработано Тогда
				ТекущаяЗапись.ДатаОбработки = ТекущаяДата();
				ТекущаяЗапись.ОписаниеОшибки = "";
			КонецЕсли;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ЧислоПопыток) Тогда
			ТекущаяЗапись.ЧислоПопыток = ЧислоПопыток;
		КонецЕсли; 
		
		Если ЗначениеЗаполнено(ОписаниеОшибки) Тогда
			ТекущаяЗапись.ОписаниеОшибки = ОписаниеОшибки;
		КонецЕсли;
				
	КонецЕсли;
	
	НаборЗаписей.Записать();

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиПодписокНаСобытия

Процедура ПриЗаписиФайла(Источник) Экспорт
	
	Если Источник.ОбменДанными.Загрузка = Истина Тогда
		Возврат;		
	КонецЕсли;
	
	Если НЕ ПолучитьФункциональнуюОпцию("ИспользоватьПредварительныйПросмотрФайлов") Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ИСТИНА КАК Поле1
	|ИЗ
	|	РегистрСведений.ИменаФайловВСервисеПросмотра КАК ИменаФайловВСервисеПросмотра
	|ГДЕ
	|	ИменаФайловВСервисеПросмотра.Файл = &Файл";
	
	Запрос.УстановитьПараметр("Файл", Источник.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если НЕ ВыборкаДетальныеЗаписи.Следующий() Тогда
		//только если не зарегистрировано имя для файла
		ДобавитьЗаписьФайлаВОчередь(Источник.Ссылка);		
	КонецЕсли;  
		
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ТекстСервисНедоступен() Экспорт

	Возврат НСтр("ru='Сервис просмотра файлов не доступен. Обратитесь к администратору'"); 

КонецФункции // ТекстСервисНедоступен()

#КонецОбласти






