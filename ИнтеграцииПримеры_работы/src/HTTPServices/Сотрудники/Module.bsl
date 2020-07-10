Функция СписокGET(Запрос)
	
	Ответ = Новый HTTPСервисОтвет(200);
	//Получить из запроса параметры URL*
	Признак = Запрос.ПараметрыURL["*"];
	
	//Сформировать выборку по сотрудникм
	Если Признак = "" Тогда
		//Без отбора
		Выборка = Справочники.Сотрудники.Выбрать();
	Иначе
		//Отбор по признаку
		Работает = ?(ВРег(Прав(Признак,2)) = "ДА", Истина, Ложь);

		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Сотрудники.Ссылка,
		|	Сотрудники.ВерсияДанных,
		|	Сотрудники.ПометкаУдаления,
		|	Сотрудники.Код,
		|	Сотрудники.Наименование,
		|	Сотрудники.Должность,
		|	Сотрудники.Работает,
		|	Сотрудники.Предопределенный,
		|	Сотрудники.ИмяПредопределенныхДанных,
		|	Сотрудники.Представление
		|ИЗ
		|	Справочник.Сотрудники КАК Сотрудники
		|ГДЕ
		|	Сотрудники.Работает = &Работает";
		
		Запрос.УстановитьПараметр("Работает", Работает);
		РезультатЗапроса = Запрос.Выполнить();

		Выборка = РезультатЗапроса.Выбрать();
	КонецЕсли;
	
	//Обход выборки и запись в JSON
	Запись = Новый ЗаписьJSON;
	Запись.УстановитьСтроку();
	
	//начало корневого элемента
	Запись.ЗаписатьНачалоОбъекта();
	Пока Выборка.Следующий() Цикл
		Запись.ЗаписатьИмяСвойства(Выборка.Наименование);
		Запись.ЗаписатьНачалоОбъекта();
		Запись.ЗаписатьИмяСвойства("Код");
		Запись.ЗаписатьЗначение(Выборка.Код);
		Запись.ЗаписатьИмяСвойства("Должность");
		Запись.ЗаписатьЗначение(Выборка.Должность);
		Запись.ЗаписатьКонецОбъекта();
	КонецЦикла;
	//Конец корневого элемента
	Запись.ЗаписатьКонецОбъекта();
	
	//Результат записи в строку JSON
	Результат = Запись.Закрыть();
	
	//Установить тело ответа из строки
	Ответ.УстановитьТелоИзСтроки(Результат);
	Ответ.Заголовки.Вставить("Conten-type", "application/json");

	Возврат Ответ;

КонецФункции

Функция СотрудникGET(Запрос)
	
	Ответ = Новый HTTPСервисОтвет(200);
	
	//Получить из запроса параметр URL "Код"
	Код = Запрос.ПараметрыURL.Получить("Код");
	Если Код = Неопределено Тогда
		Ответ = Новый HTTPСервисОтвет(400);
		Ответ.УстановитьТелоИзСтроки("Не задан параметр код");
		Ответ.Заголовки.Вставить("Conten-type", "application/json");
		Возврат Ответ;
	КонецЕсли;
	
	//Найти сотрудника в справочнике по коду из параметра URL
	СотрудникССылка = Справочники.Сотрудники.НайтиПоКоду(Код);
	Если НЕ ЗначениеЗаполнено(СотрудникССылка) Или СотрудникССылка = null  Тогда
		Ответ = Новый HTTPСервисОтвет(404);
		Ответ.УстановитьТелоИзСтроки("Employee not found");
		Ответ.Заголовки.Вставить("Conten-type", "application/json");
	КонецЕсли;
	
	Попытка
		СотрудникОбъект = СотрудникССылка.ПолучитьОбъект();
	Исключение
		Ответ = Новый HTTPСервисОтвет(400);
		Ответ.УстановитьТелоИзСтроки(Строка(ТипЗнч(СотрудникССылка)));
		Ответ.Заголовки.Вставить("Conten-type", "application/json");
	КонецПопытки;
	
//	Серриализовать данные объекта сотрудник с помощью объекта записи(запись)
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Авто, Символы.Таб);
	Запись = Новый ЗаписьJSON();
	Запись.УстановитьСтроку(ПараметрыЗаписиJSON);
	СериализаторXDTO.ЗаписатьJSON(Запись, СотрудникОбъект);
	
//	Записать результат записи в строку JSON
	Результат = Запись.Закрыть();
	
//	Установить тело ответа из строки Результат
	Ответ.УстановитьТелоИзСтроки(Результат);
	Ответ.Заголовки.Вставить("Conten-type", "application/json");
		
	Возврат Ответ;
	
КонецФункции

Функция СотрудникDELETE(Запрос)
	
//	Сформировать ответ без тела
	Ответ = Новый HTTPСервисОтвет(204);
	
//	Получить параметр код из URL запроса
	Код = Запрос.ПараметрыURL.Получить("Код");
	Если Код = Неопределено Тогда
		Ответ = Новый HTTPСервисОтвет(400);
		Ответ.УстановитьТелоИзСтроки("Have no code");
		Ответ.Заголовки.Вставить("Conten-type", "application/json");
		Возврат Ответ;
	КонецЕсли;
	
//	Найти сотрудника в справочнике по коду
	СотрудникСсылка = Справочники.Сотрудники.НайтиПоКоду(Код);
	Если СотрудникСсылка = NULL Тогда
		Ответ = Новый HTTPСервисОтвет(404);
		Ответ.УстановитьТелоИзСтроки("Сode not found");
		Ответ.Заголовки.Вставить("Conten-type", "application/json");
		Возврат Ответ;	
	КонецЕсли;
	
//	Установить найденному сотруднику пометку удаления
	СотрудникОбъект = СотрудникСсылка.ПолучитьОбъект();
	СотрудникОбъект.УстановитьПометкуУдаления(Истина); 
	СотрудникОбъект.Записать();
	
	Возврат Ответ;
	
КонецФункции
