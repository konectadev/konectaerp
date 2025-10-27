import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { FinanceOverviewComponent } from './components/finance-overview.component';

const routes: Routes = [
  {
    path: '',
    component: FinanceOverviewComponent
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class FinanceRoutingModule { }
