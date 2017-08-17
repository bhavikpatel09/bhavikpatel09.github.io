import { CurriculumVitaePage } from './app.po';

describe('curriculum-vitae App', () => {
  let page: CurriculumVitaePage;

  beforeEach(() => {
    page = new CurriculumVitaePage();
  });

  it('should display welcome message', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('Welcome to app!');
  });
});
