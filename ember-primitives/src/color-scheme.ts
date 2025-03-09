import { waitForPromise } from '@ember/test-waiters';

import { cell } from 'ember-resources';

const _colorScheme = cell<string | undefined>();

let callbacks: Set<(colorScheme: string) => void> = new Set();

async function runCallbacks(theme: string) {
  await Promise.resolve();

  for (const callback of callbacks.values()) {
    callback(theme);
  }
}

/**
 * Object for managing the color scheme
 */
export const colorScheme = {
  /**
   * Set's the current color scheme to the passed value
   */
  update: (value: string) => {
    colorScheme.current = value;

    void waitForPromise(runCallbacks(value));
  },

  on: {
    /**
     * register a function to be called when the color scheme changes.
     */
    update: (callback: (colorScheme: string) => void) => {
      callbacks.add(callback);
    },
  },
  off: {
    /**
     * unregister a function that would have been called when the color scheme changes.
     */
    update: (callback: (colorScheme: string) => void) => {
      callbacks.delete(callback);
    },
  },

  /**
   * the current valuel of the "color scheme"
   */
  get current(): string | undefined {
    return _colorScheme.current;
  },
  set current(value: string | undefined) {
    _colorScheme.current = value;

    if (!value) {
      localPreference.delete();

      return;
    }

    localPreference.update(value);
    setColorScheme(value);
  },
};

/**
 * Synchronizes state of `colorScheme` with the users preferences as well as reconciles with previously set theme in local storage.
 *
 * This may only be called once per app.
 */
export function sync() {
  /**
   * reset the callbacks
   */
  callbacks = new Set();

  /**
   * If local prefs are set, then we don't care what prefers-color-scheme is
   */
  if (localPreference.isSet()) {
    const pref = localPreference.read();

    if (pref === 'dark') {
      setColorScheme('dark');

      _colorScheme.current = 'dark';

      return;
    }

    setColorScheme('light');
    _colorScheme.current = 'light';

    return;
  }

  if (prefers.dark()) {
    setColorScheme('dark');
    _colorScheme.current = 'dark';
  } else if (prefers.light()) {
    setColorScheme('light');
    _colorScheme.current = 'light';
  }
}

/**
 * Helper methods to determining what the user's preferred color scheme is
 */
export const prefers = {
  dark: () => window.matchMedia('(prefers-color-scheme: dark)').matches,
  light: () => window.matchMedia('(prefers-color-scheme: light)').matches,
  custom: (name: string) => window.matchMedia(`(prefers-color-scheme: ${name})`).matches,
  none: () => window.matchMedia('(prefers-color-scheme: no-preference)').matches,
};

const LOCAL_PREF_KEY = 'ember-primitives/color-scheme#local-preference';

/**
 * Helper methods for working with the color scheme preference in local storage
 */
export const localPreference = {
  isSet: () => Boolean(localPreference.read()),
  read: () => localStorage.getItem(LOCAL_PREF_KEY),
  update: (value: string) => localStorage.setItem(LOCAL_PREF_KEY, value),
  delete: () => localStorage.removeItem(LOCAL_PREF_KEY),
};

/**
 * For the given element, returns the `color-scheme` of that element.
 */
export function getColorScheme(element?: HTMLElement) {
  const style = styleOf(element);

  return style.getPropertyValue('color-scheme');
}

export function setColorScheme(element: HTMLElement, value: string): void;
export function setColorScheme(value: string): void;

export function setColorScheme(...args: [string] | [HTMLElement, string]): void {
  if (typeof args[0] === 'string') {
    styleOf().setProperty('color-scheme', args[0]);

    return;
  }

  if (typeof args[1] === 'string') {
    styleOf(args[0]).setProperty('color-scheme', args[1]);

    return;
  }

  throw new Error(`Invalid arity, expected up to 2 args, received ${args.length}`);
}

/**
 * Removes the `color-scheme` from the given element
 */
export function removeColorScheme(element?: HTMLElement) {
  const style = styleOf(element);

  style.removeProperty('color-scheme');
}

function styleOf(element?: HTMLElement) {
  if (element) {
    return element.style;
  }

  return document.documentElement.style;
}
