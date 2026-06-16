# Пояснительная записка — тестовое задание AutodocNews

**Автор:** Айдумов Эльдар  
**Дата:** 04.06.2026  
**Платформа:** iOS 16+, Xcode 15+, Swift 5.9+

---

## Обзор

Приложение отображает новостную ленту Autodoc, получаемую через публичное REST API.
Реализована постраничная загрузка, кэш изображений, shimmer-плейсхолдеры, обработка ошибок и адаптивная сетка для iPad.
Сторонние зависимости не использовались.

---

## Архитектура

Паттерн **MVVM + Coordinator**:

- `NewsFeedViewModel` содержит всю бизнес-логику: управление страницей, запросы к сети, управление состоянием. `NewsFeedViewController` подписывается на `@Published`-свойства и обновляет UI.
- `NewsFeedCoordinator` отвечает за навигацию и показ системных алертов, освобождая вью-контроллер от UIKit-логики, не связанной с отображением данных.
- Combine (`sink`) соединяет состояние вью-модели с реакцией вью-контроллера через единый поток `$state`.
- `NewsFeedViewModel` помечен `@MainActor`, что исключает ручное переключение потоков при изменении `@Published`-свойств.

## Ключевые компоненты

### NetworkService

`actor NetworkService` обеспечивает доступ к общему состоянию из нескольких `Task`.
Метод `fetchNewsFeed(page:pageSize:)` формирует URL, проверяет HTTP-статус и декодирует `NewsFeedResponse` через `JSONDecoder`.

### ImageLoader

Синглтон с `NSCache<NSString, UIImage>`.
Перед отправкой запроса проверяет кэш по URL-строке как ключу.
Кэш автоматически очищается системой при нехватке памяти.

### NewsFeedViewModel

Хранит текущую страницу и `totalCount` из ответа API.
Состояние экрана моделируется через `enum ViewState { case idle, loadingFirstPage, loadingNextPage, error(String) }` — взаимоисключающие  друг друга кейсы.

Метод `loadNextPageIfNeeded` запускается как при первичной загрузке, так и при появлении footer-секции коллекции — это обеспечивает «бесконечный скролл» без таймеров или `willDisplayCell`.

Гонки предотвращаются проверкой: `guard !state.isLoading, canLoadNextPage`.
`canLoadNextPage` сравнивает количество загруженных элементов с `totalCount` — загрузка останавливается, когда все новости получены.

### NewsFeedCoordinator

Создаётся в `SceneDelegate` и владеет `UINavigationController`.
Инициализирует `NewsFeedViewModel` и `NewsFeedViewController`, связывая их.
Метод `showError(_:retryAction:)` создаёт и презентует `UIAlertController` — вся UIKit-логика ошибок сосредоточена здесь.

### NewsCell

При вызове `configure(with:)` предыдущая задача загрузки изображения отменяется (`imageLoadTask?.cancel()`).
Это исключает ситуацию, когда быстрый скролл приводит к появлению другой картинки в ячейке.
До завершения загрузки `isUserInteractionEnabled = false` — ячейку нельзя нажать, пока контент не загружен и представлен.

### ShimmerPlaceholderView

Реализует shimmer-эффект через `CABasicAnimation` по `keyPath: "locations"` на `CAGradientLayer`.
Не использует `UIView.animate`, что позволяет анимации работать независимо от главного потока отрисовки.

---

## Адаптация под iPad

Лейаут коллекции пересчитывается через closure в `UICollectionViewCompositionalLayout`:

- `horizontalSizeClass == .compact` → 1 колонка (iPhone, iPhone landscape в части режимов)
- `horizontalSizeClass == .regular` + ширина < 900pt → 2 колонки (iPad портретный режим)
- `horizontalSizeClass == .regular` + ширина ≥ 900pt → 3 колонки (iPad полноэкранный режим)

Лейаут автоматически пересчитывается при повороте экрана и изменении размера окна — `invalidateLayout` вызывать вручную не нужно.

---

## Обработка ошибок

При любой сетевой ошибке `NewsFeedViewModel` переходит в состояние `ViewState.error(String)`.
`NewsFeedViewController` наблюдает за `$state` и при кейсе `.error` делегирует показ алерта координатору.
`NewsFeedCoordinator` показывает `UIAlertController` с двумя действиями:

- **Повторить** — вызывает `loadFirstPage()`, сбрасывая страницу и данные
- **Отмена** — закрывает алерт, сохраняя уже загруженные данные

---

## Pull-to-Refresh

`UIRefreshControl` добавлен к коллекции.
По срабатыванию вызывается `viewModel.loadFirstPage()` — список обнуляется и начинается загрузка с первой страницы.
`refreshControl.endRefreshing()` вызывается при переходе `state` в `.idle`.

---

## Детальный экран

При нажатии на ячейку открывается `SFSafariViewController` с `item.fullUrl`.
Это решение выбрано намеренно: браузер обеспечивает полный рендеринг статьи без дополнительной разметки на клиенте, поддерживает Reader Mode, Shared Web Credentials и системный жест «назад».

---

## Unit-тесты

Добавлены unit-тесты, покрывающие основной фунционал работы приложения.
`NewsFeedViewModel` тестируется изолированно без создания сетевых запросов благодаря использованию протокола `NetworkServiceProtocol`.
Добавлены тесты на декодирование моделей `NewsFeedResponse` и `NewsFeedItem`, а также тесты `DateFormatter` (проверка работы форматирования строки `publishedDate`, приходящей с сервера).

---

## Чего нет (и почему)

- **Сторонние зависимости** — не использовались в соответствии с условиями задания.
- **Кэш ответов API** — не реализован, так как новостная лента всегда нуждается в свежих данных; pull-to-refresh обеспечивает явное обновление.
