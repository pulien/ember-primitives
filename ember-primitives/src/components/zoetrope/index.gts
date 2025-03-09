import "./styles.css";

import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { buildWaiter, waitForPromise } from "@ember/test-waiters";
import { isTesting, macroCondition } from "@embroider/macros";

import { modifier } from "ember-modifier";

import type { ScrollBehavior, Signature } from "./types.ts";

const testWaiter = buildWaiter("ember-primitive:zoetrope-waiter");
const DEFAULT_GAP = 8;
const DEFAULT_OFFSET = 0;

export class Zoetrope extends Component<Signature> {
  @tracked scrollerElement: HTMLElement | null = null;
  @tracked currentlyScrolled = 0;
  @tracked scrollWidth = 0;
  @tracked offsetWidth = 0;

  private setCSSVariables = modifier(
    (element: HTMLElement, _: unknown, { gap, offset }: { gap: number; offset: number }) => {
      if (gap) element.style.setProperty("--zoetrope-gap", `${gap}px`);
      if (offset) element.style.setProperty("--zoetrope-offset", `${offset}px`);
    },
  );

  scrollerWaiter = testWaiter.beginAsync();
  noScrollWaiter = () => {
    testWaiter.endAsync(this.scrollerWaiter);
  };

  private configureScroller = modifier((element: HTMLElement) => {
    this.scrollerElement = element;
    this.currentlyScrolled = element.scrollLeft;

    const zoetropeResizeObserver = new ResizeObserver(() => {
      this.scrollWidth = element.scrollWidth;
      this.offsetWidth = element.offsetWidth;
    });

    zoetropeResizeObserver.observe(element);

    element.addEventListener("scroll", this.scrollListener, { passive: true });
    element.addEventListener("keydown", this.tabListener);

    requestAnimationFrame(() => {
      testWaiter.endAsync(this.scrollerWaiter);
    });

    return () => {
      element.removeEventListener("scroll", this.scrollListener);
      element.removeEventListener("keydown", this.tabListener);

      zoetropeResizeObserver.unobserve(element);
    };
  });

  private tabListener = (event: KeyboardEvent) => {
    const target = event.target as HTMLElement;
    const { key, shiftKey } = event;

    if (!this.scrollerElement || this.scrollerElement === target) {
      return;
    }

    if (key !== "Tab") {
      return;
    }

    const nextElement = target.nextElementSibling;
    const previousElement = target.previousElementSibling;

    if ((!shiftKey && !nextElement) || (shiftKey && !previousElement)) {
      return;
    }

    event.preventDefault();

    let newTarget: HTMLElement | null = null;

    if (shiftKey) {
      newTarget = previousElement as HTMLElement;
    } else {
      newTarget = nextElement as HTMLElement;
    }

    if (!newTarget) {
      return;
    }

    newTarget?.focus({ preventScroll: true });

    const rect = getRelativeBoundingClientRect(newTarget, this.scrollerElement);

    this.scrollerElement?.scrollBy({
      left: rect.left,
      behavior: this.scrollBehavior,
    });
  };

  private scrollListener = () => {
    this.currentlyScrolled = this.scrollerElement?.scrollLeft || 0;
  };

  get offset() {
    return this.args.offset ?? DEFAULT_OFFSET;
  }

  get gap() {
    return this.args.gap ?? DEFAULT_GAP;
  }

  get canScroll() {
    return this.scrollWidth > this.offsetWidth + this.offset;
  }

  get cannotScrollLeft() {
    return this.currentlyScrolled <= this.offset;
  }

  get cannotScrollRight() {
    return this.scrollWidth - this.offsetWidth - this.offset < this.currentlyScrolled;
  }

  get scrollBehavior(): ScrollBehavior {
    if (macroCondition(isTesting())) {
      return "instant";
    }

    return this.args.scrollBehavior || "smooth";
  }

  scrollLeft = () => {
    if (!(this.scrollerElement instanceof HTMLElement)) {
      return;
    }

    const { firstChild } = this.findOverflowingElement();

    if (!firstChild) {
      return;
    }

    const children = [...this.scrollerElement.children];

    const firstChildIndex = children.indexOf(firstChild);

    let targetElement = firstChild;
    let accumalatedWidth = 0;

    for (let i = firstChildIndex; i >= 0; i--) {
      const child = children[i];

      if (!(child instanceof HTMLElement)) {
        continue;
      }

      accumalatedWidth += child.offsetWidth + this.gap;

      if (accumalatedWidth >= this.offsetWidth) {
        break;
      }

      targetElement = child;
    }

    const rect = getRelativeBoundingClientRect(targetElement, this.scrollerElement);

    this.scrollerElement.scrollBy({
      left: rect.left,
      behavior: this.scrollBehavior,
    });

    void waitForPromise(new Promise(requestAnimationFrame));
  };

  scrollRight = () => {
    if (!(this.scrollerElement instanceof HTMLElement)) {
      return;
    }

    const { activeSlide, lastChild } = this.findOverflowingElement();

    if (!lastChild) {
      return;
    }

    let rect = getRelativeBoundingClientRect(lastChild, this.scrollerElement);

    // If the card is larger than the container then skip to the next card
    if (rect.width > this.offsetWidth && activeSlide === lastChild) {
      const children = [...this.scrollerElement.children];
      const lastChildIndex = children.indexOf(lastChild);
      const targetElement = children[lastChildIndex + 1];

      if (!targetElement) {
        return;
      }

      rect = getRelativeBoundingClientRect(targetElement, this.scrollerElement);
    }

    this.scrollerElement?.scrollBy({
      left: rect.left,
      behavior: this.scrollBehavior,
    });

    void waitForPromise(new Promise(requestAnimationFrame));
  };

  private findOverflowingElement() {
    const returnObj: {
      activeSlide?: Element;
      firstChild?: Element;
      lastChild?: Element;
    } = {
      firstChild: undefined,
      lastChild: undefined,
      activeSlide: undefined,
    };

    if (!this.scrollerElement) {
      return returnObj;
    }

    const parentElement = this.scrollerElement.parentElement;

    if (!parentElement) {
      return returnObj;
    }

    const containerRect = getRelativeBoundingClientRect(this.scrollerElement, parentElement);

    const children = [...this.scrollerElement.children];

    // Find the first child that is overflowing the left edge of the container
    // and the last child that is overflowing the right edge of the container
    for (const child of children) {
      const rect = getRelativeBoundingClientRect(child, this.scrollerElement);

      if (rect.right + this.gap >= containerRect.left && !returnObj.firstChild) {
        returnObj.firstChild = child;
      }

      if (rect.left >= this.offset && !returnObj.activeSlide) {
        returnObj.activeSlide = child;
      }

      if (rect.right >= containerRect.width && !returnObj.lastChild) {
        returnObj.lastChild = child;

        break;
      }
    }

    if (!returnObj.firstChild) {
      returnObj.firstChild = children[0];
    }

    if (!returnObj.lastChild) {
      returnObj.lastChild = children[children.length - 1];
    }

    return returnObj;
  }

  <template>
    <section
      class="ember-primitives__zoetrope"
      {{this.setCSSVariables gap=this.gap offset=this.offset}}
      ...attributes
    >
      {{#if (has-block "header")}}
        <div class="ember-primitives__zoetrope__header">
          {{yield to="header"}}
        </div>
      {{/if}}

      {{#if (has-block "controls")}}
        {{yield
          (hash
            cannotScrollLeft=this.cannotScrollLeft
            cannotScrollRight=this.cannotScrollRight
            canScroll=this.canScroll
            scrollLeft=this.scrollLeft
            scrollRight=this.scrollRight
          )
          to="controls"
        }}
      {{else}}
        {{#if this.canScroll}}
          <div class="ember-primitives__zoetrope__controls">
            <button
              type="button"
              {{on "click" this.scrollLeft}}
              disabled={{this.cannotScrollLeft}}
            >Left</button>

            <button
              type="button"
              {{on "click" this.scrollRight}}
              disabled={{this.cannotScrollRight}}
            >Right</button>
          </div>
        {{/if}}
      {{/if}}
      {{#if (has-block "content")}}
        <div class="ember-primitives__zoetrope__scroller" {{this.configureScroller}}>
          {{yield to="content"}}
        </div>
      {{else}}
        {{(this.noScrollWaiter)}}
      {{/if}}
    </section>
  </template>
}

export default Zoetrope;

function getRelativeBoundingClientRect(childElement: Element, parentElement: Element) {
  if (!childElement || !parentElement) {
    throw new Error("Both childElement and parentElement must be provided");
  }

  // Get the bounding rect of the child and parent elements
  const childRect = childElement.getBoundingClientRect();
  const parentRect = parentElement.getBoundingClientRect();

  // Get computed styles of the parent element
  const parentStyles = window.getComputedStyle(parentElement);

  // Extract and parse parent's padding, and border, for all sides
  const parentPaddingTop = parseFloat(parentStyles.paddingTop);
  const parentPaddingLeft = parseFloat(parentStyles.paddingLeft);

  const parentBorderTopWidth = parseFloat(parentStyles.borderTopWidth);
  const parentBorderLeftWidth = parseFloat(parentStyles.borderLeftWidth);

  // Calculate child's position relative to parent's content area (including padding and borders)
  return {
    width: childRect.width,
    height: childRect.height,
    top: childRect.top - parentRect.top - parentBorderTopWidth - parentPaddingTop,
    left: childRect.left - parentRect.left - parentBorderLeftWidth - parentPaddingLeft,
    bottom:
      childRect.top - parentRect.top - parentBorderTopWidth - parentPaddingTop + childRect.height,
    right:
      childRect.left -
      parentRect.left -
      parentBorderLeftWidth -
      parentPaddingLeft +
      childRect.width,
  };
}
