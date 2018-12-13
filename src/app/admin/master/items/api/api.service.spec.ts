import { TestBed, inject } from '@angular/core/testing';
import { ApiItemService } from './api.service';


describe('ApiService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [ApiItemService]
    });
  });

  it('should be created', inject([ApiItemService], (service: ApiItemService) => {
    expect(service).toBeTruthy();
  }));
});