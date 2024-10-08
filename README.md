# Tracker
Приложение помогает пользователям формировать полезные привычки и контролировать их выполнение.

#### Ссылки:

[Дизайн в Figma](https://www.figma.com/design/GSDoee2Kq1ydoAyAAlW5mE/Tracker?node-id=1-2521&t=k1NwW0oXlr2pxlmg-1)

#### Цели приложения:

Контроль привычек по дням недели;
Просмотр прогресса по привычкам;

## Краткое описание приложения

Приложение состоит из карточек-трекеров, которые создает пользователь. Он может указать название, категорию и задать расписание. Также можно выбрать эмодзи и цвет, чтобы отличать карточки друг от друга.
Карточки отсортированы по категориям. Пользователь может искать их с помощью поиска и фильтровать.
С помощью календаря пользователь может посмотреть какие привычки у него запланированы на конкретный день.
В приложении есть статистика, которая отражает успешные показатели пользователя, его прогресс и средние значения.

## Функциональные требования

### Онбординг

При первом входе в приложение пользователь попадает на экран онбординга.

Экран онбординга содержит:

* Заставку;
* Заголовок и вторичный текст;
* Page controls;
* Кнопку «Вот это технологии».
  
#### Алгоритмы и доступные действия:

С помощью свайпа вправо и влево пользователь может переключаться между страницами. При переключении страницы page controls меняет состояние;
При нажатии на кнопку «Вот это технологии» пользователь переходит на главный экран.

### Создание карточки привычки

На главном экране пользователь может создать трекер для привычки или нерегулярного события. Привычка – событие, которое повторяется с определенной периодичностью. Нерегулярное событие не привязано к конкретным дням.

#### Экран создания трекера для привычки содержит:
* Заголовок экрана;
* Поле для ввода названия трекера;
* Раздел категории;
* Раздел настройки расписания;
* Раздел с эмоджи;
* Раздел с выбором цвета трекера;
* Кнопка «Отменить»;
* Кнопка «Создать».

#### Экран создания трекера для нерегулярного события содержит:
* Заголовок экрана;
* Поле для ввода названия трекера;
* Раздел категории;
* Раздел с эмоджи;
* Раздел с выбором цвета трекера;
* Кнопка «Отменить»;
* Кнопка «Создать».

#### Алгоритмы и доступные действия:

* Пользователь может создать трекер для привычки или нерегулярного события. Алгоритм создания трекеров аналогичен, но в событии отсутствует раздел расписания.
* Пользователь может ввести название трекера;
После ввода одного символа появляется иконка крестика. При нажатии на иконку пользователь может удалить введенный текст;
Максимальное количество символов – 38;
Если пользователь превысил допустимое количество, появляется текст с ошибкой;
* При нажатии на раздел «Категория» открывается экран выбора категории;
Если пользователь ранее не добавлял категории, то стоит заглушка;
Синей галочкой отмечена последняя выбранная категория;
* При нажатии на «Добавить категорию» пользователь может добавить новую.
Откроется экран с полем для ввода названия. Кнопка «Готово» неактивна;
Если введен хотя бы 1 символ, то кнопка «Готово» становится активной;
При нажатии на кнопку «Готово» закрывается экран создания категории и пользователь возвращается на экран выбора категории. Созданная категория появляется в списке категорий. Автоматического выбора, установки галочки не происходит.
При нажатии на категорию, она отмечается синей галочкой и пользователь возвращается на экран создания привычки. Выбранная категория отображается на экране создания привычки вторичным текстом под заголовком «Категория»;
* В режиме создания привычки есть раздел «Расписание». При нажатии на раздел открывается экран с выбором дней недели. Пользователь может переключить свитчер, чтобы выбрать день повторения привычки;
При нажатии на «Готово» пользователь возвращается на экран создания привычки. Выбранные дни отображаются на экране создания привычки вторичным текстом под заголовком «Расписание»;
Если пользователь выбрал все дни, то отображается текст «Каждый день»;
* Пользователь может выбрать эмодзи. Под выбранным эмодзи появляется подложка;
* Пользователь может выбрать цвет трекера. На выбранном цвете появляется обводка;
* При нажатии кнопки «Отменить» пользователь может прекратить создание привычки;
* Кнопка «Создать» неактивна пока не заполнены все разделы. При нажатии на кнопку открывается главный экран. Созданная привычка отображается в соответствующей категории;

### Просмотр главного экрана

На главном экране пользователь может просмотреть все созданные трекеры на выбранную дату, отредактировать их и посмотреть статистику.

#### Главный экран содержит:
* Кнопку «+» для добавления привычки;
* Заголовок «Трекеры»;
* Текущая дата;
* Поле для поиска трекеров;
* Карточки трекеров по категориям. Карточки содержат:
* Емодзи;
* Название трекера;
* Количество затреканных дней;
* Кнопку для отметки выполненной привычки;
* Кнопка «Фильтр»;
* Таб-бар.

#### Алгоритмы и доступные действия:

* При нажатии на «+» всплывает шторка с возможностью создать привычку или нерегулярное событие;
* При нажатии на дату открывается календарь. Пользователь может переключаться между месяцами. При нажатии на число приложение показывает соответствующие дате трекеры;
* Пользователь может искать трекеры по названию в окне поиска;
Если ничего не найдено, то пользователь видит заглушку;
* При нажатии на «Фильтры» всплывает шторка со списком фильтром;
Кнопка фильтрации отсутствует, если на выбранный день нет трекеров;
* При выборе «Все трекеры» пользователь видит все трекеры на выбранный день;
При выборе «Трекеры на сегодня» ставится текущая дата и пользователь видит все трекеры на этот день;
При выборе «Завершенные» пользователь видит привычки, которые были выполнены пользователем в выбранный день;
При выборе «Не завершенные» пользователь видит невыполненные трекеры в выбранный день;
Текущий фильтр отмечен синей галочкой;
При нажатии на фильтр шторка скрывается, на экране отображены соответствующие трекеры;
Если ничего не найдено, то пользователь видит заглушку;
* При скролле вниз и вверх пользователь может просматривать ленту;
* Если изображение карточки не успели загрузиться, то отображается системный лоадер;
* При нажатии на карточку фон под ней размывается и всплывает модальное окно;
* Пользователь может закрепить карточку. Карточка попадет в категорию «Закрепленные» в вверху списка;
* При повторном нажатии пользователь может открепить карточку;
* Если закрепленных карточек нет, то категория «Закрепленные» отсутствует;
* Пользователь может отредактировать карточку. Всплывает модальное окно с функциональностью аналогичной созданию карточки;
* При нажатии на «Удалить» всплывает action sheet.
Пользователь может подтвердить удаление карточки. Все данные о ней должны быть удалены;
Пользователь может отменить действие и вернуться на главный экран;
* С помощью таб бара пользователь может переключаться между разделами «Трекеры» и «Статистика».

### Редактирование и удаление категории
Во время создания трекера пользователь может отредактировать категории в списке или удалить ненужные.

#### Алгоритмы и доступные действия:

* При долгом нажатии на категорию из списка фон под ней размывается и появляется модальное окно;
* При нажатии на «Редактировать» всплывает модальное окно. Пользователь может отредактировать название категории. При нажатии на кнопку «Готово» пользователь возвращается в список категорий;
* При нажатии «Удалить» всплывает action sheet.
Пользователь может подтвердить удаление категории. Все данные о ней должны быть удалены;
* Пользователь может отменить действие;
После подтверждения или отмены пользователь возвращается в список категорий;

### Просмотр статистики

Во вкладке статистики пользователь может посмотреть успешные показатели, свой прогресс и средние значения.

#### Экран статистики содержит:

* Заголовок «Статистика»;
* Список со статистическими показателями. Каждый показатель содержит:
* Заголовок-цифру;
* Вторичный текст с названием показателя;
* Таб-бар

#### Алгоритмы и доступные действия:

* Если данных нет ни под одному показателю, то пользователь видит заглушку;
* Если есть данные хотя бы под одному показателю, то статистика отображается. Показатели без данных отображаются с нулевым значением;
* Пользователь может просмотреть статистику по следующим показателям:
«Лучший период» считает максимальное количество дней без перерыва по всем трекерам;
«Идеальные дни» считает дни, когда были выполнены все запланированные привычки;
«Трекеров завершено» считает общее количество выполненных привычек за все время;
«Среднее значение» считает среднее количество привычек, выполненных за 1 день.

### Темная тема
В приложении есть темная тема, которая меняется в зависимости от настроек системы устройства.

## Нефункциональные требования
Приложение должно поддерживать iPhone X и выше и адаптировано под iPhone SE, минимальная поддерживаемая версия операционной системы - iOS 13.4;
В приложении используется стандартный шрифт iOS – SF Pro.
Для хранения данных о привычках используется Core Data.
