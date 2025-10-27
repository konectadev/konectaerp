import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HrOverviewComponent } from './components/hr-overview.component';

const routes: Routes = [
  {
    path: '',
    component: HrOverviewComponent
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class HrRoutingModule { }
