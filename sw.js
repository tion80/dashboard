// Service Worker for Routine Notifications
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const tab = event.notification.data?.tab || 'focus';
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes('dashboard.html')) {
          client.postMessage({ type: 'ROUTINE_TAB_SWITCH', tab });
          return client.focus();
        }
      }
      return self.clients.openWindow('./dashboard.html#tab=' + tab);
    })
  );
});
